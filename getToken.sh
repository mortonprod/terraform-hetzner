#!/bin/bash
eval "$(jq -r '@sh "export MASTER_IP=\(.master_ip)"')"
until echo $JOIN_COMMAND| grep -q "kubeadm join";
do 
  sleep 5s 
  JOIN_COMMAND=`ssh -q -o StrictHostKeyChecking=no -i ~/.ssh/hetzner root@${MASTER_IP} "kubeadm token create --print-join-command"`
done
jq -n --arg join_command "$JOIN_COMMAND" '{"join_command":$join_command}'