#!/bin/sh

BACKGROUNDPID=-1

alias logger="echo"

stopinit() {
    # gracefully exit the stop scripts first
    for script in `ls /etc/rc6.d/ | sort -g`; do
        ! "/etc/rc6.d/$script" stop
    done
    # kill the entrypoint process
    if [ ${BACKGROUNDPID} -ne -1 ]; then
        kill -TERM "${BACKGROUNDPID}" 2>/dev/null
    fi
    # kill all process in the process group
    kill -s TERM -- -$$
}

startinit() {
    for script in `ls /etc/rc3.d/ | sort -g`; do
        ! "/etc/rc3.d/$script" start
    done
}

_term() {
    # remove this trap handler, so next time it will exit
    trap - TERM
    logger "Init: Caught SIGTERM signal!"
    stopinit
}

trap _term SIGTERM

startinit

logger "Checking for additional command to be executed"
for arg in "$@"
do
       logger "Executing '$@'"
       "$@" &
        BACKGROUNDPID=$!
        break
done

# expecting this wait to fail due to nature of the shell scripts
wait -n

if [ ${BACKGROUNDPID} -ne -1 ]; then
    logger "Wait for Entrypoint"
    # wait for explicit process
    wait ${BACKGROUNDPID}
    EXITCODE=$?
    BACKGROUNDPID=-1
    logger "Process ended with ${EXITCODE}"
else
    # TODO: Implement
    logger "Cannot wait for any process to exit - will only exit on signal"
    # wait for all background process to complete/exit
    # or get the signal
    read -u 2
    EXITCODE=$?
    logger "Some process ended with ${EXITCODE}"
fi


# Stop init again, if we didnt get SIGTERM we will have
# gracefully stop all started processes.
logger "Trying to gracefully stop the other processes"
trap - TERM
stopinit

logger "Exiting with ${EXITCODE}"
exit ${EXITCODE}
