#!/bin/bash

TYPE="$1"
NAME="$2"
STATE="$3"

LOGFILE="/var/log/keepalived_notify.log"

function logmsg()
{
   MSG="$*"
   echo "$(date +'%F %T') ${MSG}" >> ${LOGFILE}
   echo "#########################################################################################################" >> ${LOGFILE}
}

logmsg "${TYPE} - ${NAME} - ${STATE}"

function become_master()
{
   logmsg "Node become MASTER."
}


function become_backup()
{
   logmsg "Node become BACKUP."
}


function service_stop()
{
   logmsg "Keepalived service stop."
}


function service_fault()
{
   logmsg "Keepalived service fault."
}


case "${STATE}" ｉｎ
"MASTER")
   become_master
   ;;
"BACKUP")
   become_backup
   ;;
"STOP")
   service_stop
   ;;
"FAULT")
   service_fault
   ;;
*)
   logmsg "unknow state: ${STATE}."
   ;;
esac
