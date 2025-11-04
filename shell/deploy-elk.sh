# #!/bin/bash

sudo apk add envsubst -f

# # IP MetalLB fixe pour Kibana
 export KIBANA_IP=$NETWORK_PREFIX.210
 echo "IP de KIBANA : $KIBANA_IP"

echo "installation des CRD (custom resourses definition) et déploiement de l'ElasticOperator"
kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/operator.yaml
echo "📦 Déploiement de la stack Kibana avec IP $KIBANA_IP"

export KIBANA_PATH=/vagrant/yaml/elk
kubectl apply -f $KIBANA_PATH/elk-namespace.yaml
kubectl apply -f $KIBANA_PATH/elasticsearch.yaml
kubectl apply -f $KIBANA_PATH/logstash-config.yaml
kubectl apply -f $KIBANA_PATH/logstash.yaml
kubectl apply -f $KIBANA_PATH/kibana.yaml

echo "✅ Déploiement terminé. Accès Kibana : http://${KIBANA_IP}:5601"