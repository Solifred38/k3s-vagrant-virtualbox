#!/bin/bash

sudo apk add envsubst -f

# # IP MetalLB fixe pour Kibana
 export KIBANA_IP=$NETWORK_PREFIX.210
 export ES_IP=$NETWORK_PREFIX.211
 echo "IP de KIBANA : $KIBANA_IP"

echo "installation des CRD (custom resourses definition) et déploiement de l'ElasticOperator"
kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/operator.yaml
echo "📦 Déploiement de la stack Kibana avec IP $KIBANA_IP"

export KIBANA_PATH=/vagrant/apps/elk/yaml
kubectl apply -f $KIBANA_PATH/elk-namespace.yaml
envsubst < $KIBANA_PATH/elasticsearch.yaml | kubectl apply -f -
kubectl apply -f $KIBANA_PATH/logstash-config.yaml
kubectl apply -f $KIBANA_PATH/logstash.yaml
envsubst < $KIBANA_PATH/kibana.yaml | kubectl apply -f -
kubectl apply -f $KIBANA_PATH/metricbeat-kubernetes.yaml
echo "✅ Déploiement terminé. Accès Kibana : http://${KIBANA_IP}:5601"