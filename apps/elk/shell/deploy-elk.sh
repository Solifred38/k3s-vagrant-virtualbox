#!/bin/bash
sudo chmod +x ./set-env-var.sh
. ./set-env-var.sh
# echo "suppression de l'ancienne stack"
# kubectl delete namespace elastic-system
 
#  export KIBANA_SERVICE_TOKEN="AAEAAWVsYXN0aWMva2liYW5hL2tpYmFuYS10b2tlbjoxejFzZ25DM1NONm9ldGJVZlVENy1n"
#  echo "IP de KIBANA : $KIBANA_IP"

# echo "installation des CRD (custom resourses definition) et déploiement de l'ElasticOperator"
# kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/crds.yaml
# kubectl apply -f https://download.elastic.co/downloads/eck/2.10.0/operator.yaml
echo "📦 Déploiement de la stack Kibana avec IP $KIBANA_IP"

export KIBANA_PATH=/vagrant/apps/elk/yaml

envsubst < $KIBANA_PATH/elk-stack.yaml | kubectl apply -f -

echo "attente que tous les pods soient prets"
echo "attente que les pods soient ready"
# 3. Attendre que les pods soient prêts
kubectl wait --for=condition=ready pod -l app=elasticsearch -n elastic-system --timeout=600s
kubectl wait --for=condition=ready pod -l app=kibana -n elastic-system --timeout=600s
kubectl wait --for=condition=ready pod -l app=logstash -n elastic-system --timeout=300s

echo "🎉 Stack ELK déployé automatiquement avec Kibana, Beats et Logstash configurés"
sudo kubectl config set-context --current --namespace elastic-system
# import des dashboard
kubectl apply -f $KIBANA_PATH/filebeat-import-dashboard-job.yaml
kubectl apply -f $KIBANA_PATH/metricbeat-import-dashboard-job.yaml

# import des objets dans kibana
#curl -X POST "http://$KIBANA_IP:5601/api/saved_objects/_import?overwrite=true" \
#  -H "kbn-xsrf: true" \
#  -H "Content-Type: multipart/form-data" \
#  -F "file=@../yaml/dashboard.ndjson"

