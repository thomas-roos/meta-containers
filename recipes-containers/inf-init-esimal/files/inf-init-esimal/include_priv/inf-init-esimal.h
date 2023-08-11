/****************************************************************************
**
** Copyright (c) 2020 SoftAtHome
**
** Redistribution and use in source and binary forms, with or
** without modification, are permitted provided that the following
** conditions are met:
**
** 1. Redistributions of source code must retain the above copyright
** notice, this list of conditions and the following disclaimer.
**
** 2. Redistributions in binary form must reproduce the above
** copyright notice, this list of conditions and the following
** disclaimer in the documentation and/or other materials provided
** with the distribution.
**
** Subject to the terms and conditions of this license, each
** copyright holder and contributor hereby grants to those receiving
** rights under this license a perpetual, worldwide, non-exclusive,
** no-charge, royalty-free, irrevocable (except for failure to
** satisfy the conditions of this license) patent license to make,
** have made, use, offer to sell, sell, import, and otherwise
** transfer this software, where such license applies only to those
** patent claims, already acquired or hereafter acquired, licensable
** by such copyright holder or contributor that are necessarily
** infringed by:
**
** (a) their Contribution(s) (the licensed copyrights of copyright
** holders and non-copyrightable additions of contributors, in
** source or binary form) alone; or
**
** (b) combination of their Contribution(s) with the work of
** authorship to which such Contribution(s) was added by such
** copyright holder or contributor, if, at the time the Contribution
** is added, such addition causes such combination to be necessarily
** infringed. The patent license shall not apply to any other
** combinations which include the Contribution.
**
** Except as expressly stated above, no rights or licenses from any
** copyright holder or contributor is granted under this license,
** whether expressly, by implication, estoppel or otherwise.
**
** DISCLAIMER
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
** CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
** INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
** MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
** CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
** USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
** AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
** LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
** ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
** POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************/

#if !defined(__MAIN_H__)
#define __MAIN_H__

#ifdef __cplusplus
extern "C"
{
#endif

#define MAX_SIZE_SCRIPT 256
#define MAX_NO_START_SCRIPTS 120
#define INFINITESIMAL_ENV_KEY_PIDFILE "INFINITESIMAL_BELOVED_PIDFILE"

int spawn(char* const argv[], int* const child_pid_ptr);
void sort_scripts_alphabetically(char script_arr[][MAX_SIZE_SCRIPT], unsigned int amount);
int execute_init_scripts(const char* path, const char firstchar, const char* command, long sleep_msec, int wait);
int read_pid_file(const char* filepath);
ssize_t syslog_writer(void* cookie, const char* data, size_t size);
void redirectlog(FILE** pfp, int* defaultpriority);
void spawn_reader(int readfd, pid_t pid);

#define PRINT_FN(p, prefmt, ...) \
    do { \
        syslog(p, prefmt __VA_ARGS__); \
    } while(0)

#define PRINT_EMERG(...)    PRINT_FN(LOG_EMERG, "EMERG: ", __VA_ARGS__)
#define PRINT_ALERT(...)    PRINT_FN(LOG_ALERT, "ALERT: ", __VA_ARGS__)
#define PRINT_CRIT(...)     PRINT_FN(LOG_CRIT, "CRIT: ", __VA_ARGS__)
#define PRINT_ERR(...)      PRINT_FN(LOG_ERR, "ERR: ", __VA_ARGS__)
#define PRINT_WARNING(...)  PRINT_FN(LOG_WARNING, "WARNING: ", __VA_ARGS__)
#define PRINT_NOTICE(...)   PRINT_FN(LOG_NOTICE, "NOTICE: ", __VA_ARGS__)
#define PRINT_INFO(...)     PRINT_FN(LOG_INFO, "INFO: ", __VA_ARGS__)
#define PRINT_DEBUG(...)    PRINT_FN(LOG_DEBUG, "DEBUG: ", __VA_ARGS__)
#define PRINT_CHILD(...)  \
    do { \
        syslog(LOG_NOTICE, "CHILD: " __VA_ARGS__); \
    } while(0)


#ifdef __cplusplus
}
#endif


#endif // __MAIN_H__
