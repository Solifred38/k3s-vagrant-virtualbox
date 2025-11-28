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
echo $NETWORK_PREFIX
# # IP MetalLB fixe pour Kibana
 export KIBANA_IP=$NETWORK_PREFIX.210
 export ELASTIC_IP=$NETWORK_PREFIX.211
