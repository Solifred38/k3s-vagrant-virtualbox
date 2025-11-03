#!/bin/bash

# IP MetalLB fixe pour Kibana
export KIBANA_IP=192.168.10.210
kubectl delete ns elk
sudo apk add envsubst -f
kubectl create namespace elk

echo "installation des CRD (custom resourses definition) et déploiement de l'ElasticOperator"
kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/operator.yaml
echo "📦 Déploiement de la stack Kibana avec IP $KIBANA_IP"

export KIBANA_PATH=/vagrant/yaml/elk
# Etape 0 : installation d'elasticsearch
echo "creation elasticsearch"
kubectl apply -f $KIBANA_PATH/elasticsearch.yaml
# Étape 1 : ConfigMap
echo "🔧 Création du ConfigMap..."
envsubst < $KIBANA_PATH/kibana-configmap.yaml | kubectl apply -f -

# Étape 2 : Déploiement Kibana via Elastic Operator
echo "🚀 Déploiement de Kibana..."
kubectl apply -f  $KIBANA_PATH/kibana.yaml

# Attente que Kibana soit prêt
echo "⏳ Attente que Kibana soit prêt..."
kubectl wait --for=condition=ready pod -l kibana.k8s.elastic.co/name=quickstart -n elk --timeout=180s

# Étape 3 : Service LoadBalancer MetalLB
echo "🌐 Exposition de Kibana via MetalLB..."
envsubst < $KIBANA_PATH/kibana-lb.yaml | kubectl apply -f -

# Étape 4 : Déploiement du client
echo "🧪 Déploiement du client Kibana..."
envsubst < $KIBANA_PATH/kibana-client.yaml | kubectl apply -f -

echo "✅ Déploiement terminé. Accès Kibana : http://${KIBANA_IP}:5601"