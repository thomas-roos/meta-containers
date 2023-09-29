#!/bin/sh

PIDFILE=/run/ubus.pid

case $1 in
    boot|start)
        ubusd &
        PID=$!
        echo "${PID}" > ${PIDFILE}
    ;;
    stop)
        kill -9 $(cat ${PIDFILE})
        ! rm ${PIDFILE}
    ;;
    reload)
        echo "No reload"
    ;;
    restart|fail)
        $0 stop
        $0 start
    ;;
    *)
esac
