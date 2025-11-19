#!/bin/bash

sudo apk add envsubst -f


# # IP MetalLB fixe pour Kibana
 export KIBANA_IP=$NETWORK_PREFIX.210
 export ES_IP=$NETWORK_PREFIX.211
 export KIBANA_SERVICE_TOKEN="AAEAAWVsYXN0aWMva2liYW5hL2tpYmFuYS10b2tlbjoxejFzZ25DM1NONm9ldGJVZlVENy1n"
 echo "IP de KIBANA : $KIBANA_IP"

echo "installation des CRD (custom resourses definition) et déploiement de l'ElasticOperator"
kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/operator.yaml
echo "📦 Déploiement de la stack Kibana avec IP $KIBANA_IP"

export KIBANA_PATH=/vagrant/apps/elk/yaml


kubectl apply -f $KIBANA_PATH/secret.yaml

envsubst < $KIBANA_PATH/elasticsearch.yaml | kubectl apply -f -
envsubst < $KIBANA_PATH/kibana.yaml | kubectl apply -f -
kubectl apply -f $KIBANA_PATH/filebeat.yaml
kubectl apply -f $KIBANA_PATH/metricbeat.yaml
kubectl apply -f $KIBANA_PATH/logstash.yaml
kubectl apply -f $KIBANA_PATH/logstash-pipeline.yaml

echo "attente que tous les pods soient prets"
echo "attente que les pods soient ready"
# 3. Attendre que les pods soient prêts
kubectl wait --for=condition=ready pod -l app=elasticsearch -n elastic-system --timeout=600s
kubectl wait --for=condition=ready pod -l app=kibana -n elastic-system --timeout=600s
kubectl wait --for=condition=ready pod -l app=logstash -n elastic-system --timeout=300s
# 4. Récupérer les mots de passe depuis le Secret
ELASTIC_PASS=$(kubectl get secret elastic-credentials -n elastic-system -o jsonpath='{.data.ELASTIC_PASSWORD}' | base64 -d)
KIBANA_PASS=$(kubectl get secret elastic-credentials -n elastic-system -o jsonpath='{.data.KIBANA_SYSTEM_PASSWORD}' | base64 -d)
BEATS_PASS=$(kubectl get secret elastic-credentials -n elastic-system -o jsonpath='{.data.BEATS_SYSTEM_PASSWORD}' | base64 -d)
LOGSTASH_PASS=$(kubectl get secret elastic-credentials -n elastic-system -o jsonpath='{.data.LOGSTASH_SYSTEM_PASSWORD}' | base64 -d)

# 5. Lancer un port-forward vers Elasticsearch
kubectl port-forward -n elastic-system deploy/elasticsearch 9200:9200 &
PF_PID=$!

# Attendre que le tunnel soit actif
sleep 10

# 6. Configurer les comptes système via ton curl local
echo "🔑 Configuration du compte kibana_system..."
curl -u elastic:$ELASTIC_PASS -X POST \
  "http://localhost:9200/_security/user/kibana_system/_password" \
  -H 'Content-Type: application/json' \
  -d "{\"password\":\"$KIBANA_PASS\"}"

echo "🔑 Configuration du compte beats_system..."
curl -u elastic:$ELASTIC_PASS -X POST \
  "http://localhost:9200/_security/user/beats_system/_password" \
  -H 'Content-Type: application/json' \
  -d "{\"password\":\"$BEATS_PASS\"}"

echo "🔑 Configuration du compte logstash_system..."
curl -u elastic:$ELASTIC_PASS -X POST \
  "http://localhost:9200/_security/user/logstash_system/_password" \
  -H 'Content-Type: application/json' \
  -d "{\"password\":\"$LOGSTASH_PASS\"}"

# 7. Nettoyer le port-forward
kill $PF_PID

echo "🎉 Stack ELK déployé automatiquement avec Kibana, Beats et Logstash configurés"
sudo kubectl config set-context --current --namespace elastic-system

