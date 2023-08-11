#define _GNU_SOURCE

#include <sys/types.h>
#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <dirent.h>
#include <time.h>
#include <stdint.h>
#include <signal.h>
#include <sys/wait.h>
#include <stdlib.h>
#include <time.h>
#include <syslog.h>

#include "inf-init-esimal.h"

static int global_child_pid = 0;
static int break_wait_loop = 0;
static cookie_io_functions_t log_fns = {
    NULL, syslog_writer, NULL, NULL
};

ssize_t syslog_writer(void* cookie, const char* data, size_t size) {
    int defaultpriority = *((int*) cookie);
    syslog(defaultpriority, "%.*s", (int) size, data);
    return (ssize_t) size;
}

void redirectlog(FILE** pfp, int* defaultpriority) {
    setvbuf(*pfp = fopencookie((void*) defaultpriority, "w", log_fns), NULL, _IOLBF, 0);
}

void spawn_reader(int readfd, pid_t pid) {
    char buffer[BUFSIZ];
    while(1) {
        ssize_t count = read(readfd, buffer, BUFSIZ);
        switch(count) {
        case -1:
            if(errno != EINTR) {
                PRINT_ERR("Cannot read pipe anymore (for pid %d): (%d) %s", pid, errno, strerror(errno));
                exit(-1);
            }
            break;
        case 0:
            PRINT_ERR("Empty read on pipe (for pid %d)", pid);
            close(readfd);
            exit(0);
        default:
            PRINT_CHILD("[PID %d] %.*s", pid, (int) count, buffer);
            break;
        }
    }
    // Don't leak into parent
    exit(-123);
}

int spawn(char* const argv[], int* const child_pid_ptr) {
    pid_t pid;
    int fdpipe[2] = {-1, -1};
    if(pipe(fdpipe) == -1) {
        PRINT_ERR("Can't create pipe: (%d) %s", errno, strerror(errno));
    }

    pid = fork();
    if(pid < 0) {
        PRINT_ERR("fork failed: %s", strerror(errno));
        return -1;
    } else if(pid == 0) {
        if(fdpipe[1] > -1) {
dupstdout:
            if(dup2(fdpipe[1], STDOUT_FILENO) == -1) {
                if(errno == EINTR) {
                    goto dupstdout;
                }
                PRINT_ERR("dup2 - STDOUT: (%d) %s", errno, strerror(errno));
            }
dupstderr:
            if(dup2(fdpipe[1], STDERR_FILENO) == -1) {
                if(errno == EINTR) {
                    goto dupstderr;
                }
                PRINT_ERR("dup2 - STDERR: (%d) %s", errno, strerror(errno));
            }
            close(fdpipe[1]);
            close(fdpipe[0]);
        }
        // Put the child into a new process group.
        if(setpgid(0, 0) < 0) {
            PRINT_ERR("setpgid failed: %s", strerror(errno));
            return 1;
        }

        // Execute program - Normally does not return
        execvp(argv[0], argv);

        PRINT_ERR("exec %s failed: %s", argv[0], strerror(errno));
        // Don't leak into parent
        exit(-123);
    } else {
        // Parent
        pid_t pidreader;
        PRINT_INFO("Spawned child process '%s' with pid '%i'", argv[0], pid);
        *child_pid_ptr = pid;
        close(fdpipe[1]);
        pidreader = fork();
        if(pidreader < 0) {
            PRINT_ERR("fork failed for reader (for pid %d): %s", pid, strerror(errno));
            close(fdpipe[0]);
            return 0;
        } else if(pidreader == 0) {
            spawn_reader(fdpipe[0], pid);
            // Don't leak into parent
            exit(-123);
        } else {
            PRINT_INFO("Started reader process (pid %d --> for pid %d)", pidreader, pid);
            close(fdpipe[0]);
            return 0;
        }
    }
}

void sort_scripts_alphabetically(char script_arr[][MAX_SIZE_SCRIPT], unsigned int amount) {
    char storage[MAX_SIZE_SCRIPT];

    for(unsigned int i = 0; i < amount; i++) {
        for(unsigned int j = i + 1; j < amount; j++) {
            if(strcmp(script_arr[i], script_arr[j]) > 0) {
                strcpy(storage, script_arr[i]);
                strcpy(script_arr[i], script_arr[j]);
                strcpy(script_arr[j], storage);
            }
        }
    }
}

int execute_init_scripts(const char* path, const char firstchar, const char* command, long sleep_msec, int wait) {
    DIR* d;
    struct dirent* dir;
    char script_arr[MAX_NO_START_SCRIPTS][MAX_SIZE_SCRIPT];
    unsigned int script_arr_counter = 0;
    char* argument_list[] = {"/bin/sh", "-c", NULL, NULL};
    int child_pid = 0;
    struct timespec req;
    struct timespec rem;

    PRINT_INFO("execute_init_scripts: %s | %c | %s", path, firstchar, command);

    d = opendir(path);
    if(d == NULL) {
        PRINT_WARNING("Could not open '%s': (%d) %s", path, errno, strerror(errno));
        return -1;
    }

    while(( dir = readdir(d)) != NULL) {
        if((dir->d_type == DT_LNK) && (dir->d_name[0] == firstchar)) {
            int ret = snprintf(script_arr[script_arr_counter], MAX_SIZE_SCRIPT, "%s/%s %s", path, dir->d_name, command);
            if((ret < 1) || (ret > MAX_SIZE_SCRIPT)) {
                PRINT_ERR("Could not write script to the array [%d]", ret);
            } else {
                if(++script_arr_counter == MAX_NO_START_SCRIPTS) {
                    PRINT_ERR("There are more then %d scripts", script_arr_counter);
                    break;
                }
            }
        }
    }
    closedir(d);

    sort_scripts_alphabetically(script_arr, script_arr_counter);

    if(sleep_msec > 0) {
        req.tv_sec = sleep_msec / 1000;
        req.tv_nsec = (sleep_msec % 1000) * 1000000;
    }

    for(unsigned int i = 0; i < script_arr_counter; i++) {
        argument_list[2] = script_arr[i];
        PRINT_INFO("Starting: %s", argument_list[2]);
        spawn(argument_list, &child_pid);
        PRINT_INFO("PID: %d", child_pid);
        if(wait) {
            int status;
            int returncode;
            int got_pid;

            PRINT_INFO("Waiting for PID: %d", child_pid);
            do {
                got_pid = waitpid(child_pid, &status, 0);
            } while(got_pid == -1 && errno == EINTR);
            if(got_pid < 1) {
                PRINT_ERR("waitpid() error: (%d) %s - continue to next init script", errno, strerror(errno));
            } else {
                if(WIFEXITED(status)) { /* process exited normally */
                    returncode = WEXITSTATUS(status);
                    PRINT_INFO("Init child process (%d) exited with value: %d", got_pid, returncode);
                } else if(WIFSIGNALED(status)) { /* child exited on a signal */
                    returncode = WTERMSIG(status);
                    PRINT_INFO("Init child process (%d) exited due to signal: %d", got_pid, returncode);
                } else if(WIFSTOPPED(status)) { /* child was stopped */
                    returncode = WIFSTOPPED(status);
                    PRINT_INFO("Init child process (%d) was stopped by signal: %d", got_pid, returncode);
                }
            }
        }
        if(sleep_msec > 0) {
            int nanosleepret;
            PRINT_INFO("Sleeping %ld", sleep_msec);
            nanosleepret = nanosleep(&req, &rem);
            PRINT_INFO("Nanosleep: %d - EINTR: %d | remaining [%ld:%ld]",
                       nanosleepret,
                       (errno == EINTR),
                       rem.tv_sec, rem.tv_nsec);
        }
    }

    return 0;
}

int read_pid_file(const char* filepath) {
    FILE* pidfile;
    long int pid;
    char buffer[24];
    size_t readbytes = 0;

    pidfile = fopen(filepath, "r");
    if(pidfile == NULL) {
        PRINT_ERR("Can't open pidfile: %s - (%d) %s", filepath, errno, strerror(errno));
        return -1;
    }

    readbytes = fread(buffer + readbytes, sizeof(char), sizeof(buffer) - readbytes, pidfile);

    if(!feof(pidfile)) {
        PRINT_INFO("Didnt reach EOF");
    }

    fclose(pidfile);

    if(readbytes == 0) {
        PRINT_ERR("Empty file '%s'", filepath);
        return -3;
    }

    buffer[readbytes] = '\0';
    pid = strtol(buffer, NULL, 10);
    if(errno) {
        PRINT_ERR("Could not parse the pidfile (%d): %s", errno, strerror(errno));
        PRINT_ERR("Contents: '%s'", buffer);
        return -4;
    }

    PRINT_INFO("Got a Pid value (%ld) for the beloved child process from '%s'", pid, filepath);

    return (int) pid;
}

static void exit_signal_handler(int signum) {
    switch(signum) {
    case SIGPWR:
        PRINT_INFO("exit_signal_handler: SIGPWR");
        break;
    case SIGINT:
        PRINT_INFO("exit_signal_handler: SIGINT");
        break;
    case SIGTERM:
        PRINT_INFO("exit_signal_handler: SIGTERM");
        break;
    default:
        PRINT_INFO("exit_signal_handler: %d", signum);
    }

    if(global_child_pid > 0) {
        // Send SIGTERM to "beloved child process"
        // this in turn will exit the wait loop
        // if the child process terminates
        PRINT_INFO("Send SIGTERM to (%d)", global_child_pid);
        kill(global_child_pid, SIGTERM);
    } else {
        // Break wait loop manually to execute the stop scripts
        // if there is no "beloved child process"
        PRINT_INFO("Break wait loop (%d)", global_child_pid);
        break_wait_loop = 1;
    }
}

int main(int argc, char* argv[]) {
    // Execute background process if its there
    int returncode = -1;
    int got_pid = 0;
    int status;
    const char* pidfile = NULL;
    int logpriority_stdout = LOG_INFO;
    int logpriority_stderr = LOG_ERR;

    // setup syslog
    openlog(NULL, LOG_CONS | LOG_PID | LOG_ODELAY, LOG_USER);
    redirectlog(&stderr, &logpriority_stderr);
    redirectlog(&stdout, &logpriority_stdout);

    // get pidfile from env
    pidfile = getenv(INFINITESIMAL_ENV_KEY_PIDFILE);

    // set up signal handlers
    signal(SIGPWR, exit_signal_handler);
    signal(SIGTERM, exit_signal_handler);
    signal(SIGINT, exit_signal_handler);

    execute_init_scripts("/etc/rc3.d/", 'S', "start", 0, 1);

    if(argc > 1) {
        int ret = 0;
        unsigned int argcount = 1;
        struct timespec sleepts;
        sleepts.tv_sec = 0;
        sleepts.tv_nsec = 150 * 1000000;

        PRINT_INFO("Attempting to start beloved child process");
        // Ignore "--", we still allow it for (future) compatibility though
        if((argv[1][0] == '-') && (argv[1][1] == '-') && (argv[1][2] == '\0')) {
            PRINT_INFO("'--' detected");
            argcount = 2;
        }

        PRINT_INFO("Sleeping [%ld:%ld]", sleepts.tv_sec, sleepts.tv_nsec);
        do {
            ret = nanosleep(&sleepts, &sleepts);
        } while(ret && errno == EINTR);

        ret = spawn(argv + argcount, &global_child_pid);
        if(ret != 0) {
            PRINT_WARNING("Could not launch the beloved child process (%d)!", ret);
            return -1;
        }
    } else if(pidfile) {
        unsigned int pidcounter = 0;

        PRINT_INFO("Found " INFINITESIMAL_ENV_KEY_PIDFILE " : '%s'", pidfile);
        for(; (global_child_pid < 1 && pidcounter < 6); pidcounter++) {
            int ret = 0;
            struct timespec sleepts;
            sleepts.tv_sec = 0;
            sleepts.tv_nsec = 150 * 1000000;

            PRINT_INFO("Sleeping [%ld:%ld]", sleepts.tv_sec, sleepts.tv_nsec);
            do {
                ret = nanosleep(&sleepts, &sleepts);
            } while(ret && errno == EINTR);

            global_child_pid = read_pid_file(pidfile);
            PRINT_INFO("[ #%u ] read_pid_file returned %d", pidcounter, global_child_pid);
            if(global_child_pid > 0) {
                PRINT_INFO("Got PID from pidfile to monitor: %d", global_child_pid);
                break;
            }
        }
    } else {
        PRINT_INFO("The environment variable " INFINITESIMAL_ENV_KEY_PIDFILE " was not found.");
    }

    while(!break_wait_loop) {
        got_pid = wait(&status);
        if(got_pid < 1) {
            PRINT_ERR("wait() error: (%d) %s", errno, strerror(errno));
            if(errno != EINTR) {
                // Exit in case of real error
                // like no children to wait on
                return -123;
            }
        } else {
            if(WIFEXITED(status)) { /* process exited normally */
                returncode = WEXITSTATUS(status);
                PRINT_INFO("child process (%d) exited with value: %d", got_pid, returncode);
            } else if(WIFSIGNALED(status)) { /* child exited on a signal */
                returncode = WTERMSIG(status);
                PRINT_INFO("child process (%d) exited due to signal: %d", got_pid, returncode);
            } else if(WIFSTOPPED(status)) { /* child was stopped */
                returncode = WIFSTOPPED(status);
                PRINT_INFO("child process (%d) was stopped by signal: %d", got_pid, returncode);
            }
            if(global_child_pid > 0) {
                if(got_pid == global_child_pid) {
                    PRINT_ERR("Our beloved Child process (%d) has died: [%d]", global_child_pid, returncode);
                    break;
                }
            } else {
                PRINT_WARNING("No beloved child process to monitor, so we keep looping forever [%d]", got_pid);
            }
        }
    }

    PRINT_INFO("Trying to gracefully stop all processes [%d]", returncode);
    execute_init_scripts("/etc/rc6.d/", 'K', "stop", 0, 0);

    PRINT_INFO("Send SIGTERM to all processes of the same process group (returncode: %d)", returncode);
    kill(0, SIGTERM);

    return returncode;
}
