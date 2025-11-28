#!/bin/bash
# import des objets dans kibana
sudo chmod +x ./set-env-var.sh
. ./set-env-var.sh
echo "addresse ip kibana $KIBANA_IP"
curl -X POST "http://$KIBANA_IP:5601/api/saved_objects/_import?overwrite=true" \
  -H "kbn-xsrf: true" \
  -H "Content-Type: multipart/form-data" \
  -F "file=@../yaml/dashboard.ndjson"
