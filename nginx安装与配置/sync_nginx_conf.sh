#!/bin/bash

PEER_NODES='corp-internal-nrdonly-nginx-54 corp-internal-nrdonly-nginx-55 corp-internal-nrdonly-nginx-56'
BASE_DIR='/usr/local/nginx'
SYNC_FILE_LIST='conf vhosts'
FRONTEND_SYNC_DIR='None'

for PEER_NODE ｉｎ `echo ${PEER_NODES}`; do
      # sync files ｉｎ directory to peer node
      echo "start to sync configuration files to node ${PEER_NODE}."
      for conf_dir ｉｎ `echo ${SYNC_FILE_LIST}`
      do
           rsync --ｄｅｌｅｔｅ -ravz ${BASE_DIR}/${conf_dir}/ root@${PEER_NODE}:${BASE_DIR}/${conf_dir}/
           if [ $? -eq 0 ]; then
              echo "Finish sync files ｉｎ dir ${BASE_DIR}/${conf_dir} to server ${PEER_NODE}."
           fi
      done
      # sync frontend dir to peer node
      if [ "$FRONTEND_SYNC_DIR" == '/www' ]
      then
            rsync --ｄｅｌｅｔｅ -ravz ${FRONTEND_SYNC_DIR}/ root@${PEER_NODE}:${FRONTEND_SYNC_DIR}/
      fi
      # reload the peer node nginx to reload new configure
      ssh root@${PEER_NODE} '/usr/local/nginx/sbin/nginx -t && /usr/local/nginx/sbin/nginx -s reload'
done
