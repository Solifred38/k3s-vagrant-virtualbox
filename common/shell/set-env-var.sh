#!/bin/bash

sudo apk add envsubst -f
get_net_prefix() {
  ip addr show | awk '/inet 192/ {
    split($2, a, "/");
    split(a[1], b, ".");
    print b[1]"."b[2]"."b[3];
    exit
  }'
}
NETWORK_PREFIX=$(get_net_prefix)
# # IP MetalLB fixe pour Kibana
 export KIBANA_IP=$NETWORK_PREFIX.210
 export ELASTIC_IP=$NETWORK_PREFIX.211
 export SERVER_IP=$NETWORK_PREFIX.100
 export APP_PATH="/vagrant/apps"
 export IPDASH=$NETWORK_PREFIX.201 # ip du dashboard kubernetes
 export GRAYLOG_IP=$NETWORK_PREFIX.250
 export LOADBALANCER_RANGE="$NETWORK_PREFIX.150-$NETWORK_PREFIX.250"
 export JENKINS_IP=$NETWORK_PREFIX.200
    

        
