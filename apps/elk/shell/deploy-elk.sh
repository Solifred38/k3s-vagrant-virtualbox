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
 export ES_IP=$NETWORK_PREFIX.211
 echo "suppression de l'ancienne stack"
 kubectl delete namespace elastic-system
 
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

