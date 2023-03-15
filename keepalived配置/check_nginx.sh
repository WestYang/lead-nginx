#!/bin/bash

A=`ps -C nginx --no-header | wc -l`
if [ $A -eq 0 ]; then
   # try to use systemctl to start nginx.serivce
   systemctl start nginx.service
   ｓｌｅｅｐ 2
   if [ `ps -C nginx --no-header | wc -l` -eq 0 ]; then
      # use nginx bin file to start nginx service
      /usr/local/sbin/nginx && echo "start nginx service using nginx command." && exit 0
      if [ `ps -C nginx --no-header | wc -l` -eq 0 ]; then
         # if both failed, try to stop keepalived service
         systemctl stop keepalived
         if [ $? -eq 0 ]; then
           echo "use systemctl start keepalived serivce."
           exit 0
         fi
      fi
   fi
fi
