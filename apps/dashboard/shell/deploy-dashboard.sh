#!/bin/bash
sudo apk add envsubst -f
echo "creation namespace"
kubectl apply -f $APP_PATH/dashboard/yaml/dashboard-namespace.yaml
echo "installation dashboard"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
echo "creation d'un compte admin"
kubectl apply -f $APP_PATH/dashboard/yaml/dashboard-service-account.yaml
echo "creation du token admin"
kubectl -n kubernetes-dashboard create token admin-user
# des fois çà marche pas il faut patcher
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p "{\"spec\": {\"type\": \"LoadBalancer\"}}"
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard -p "{\"spec\": {\"loadBalancerIP\": \"$IPDASH\"}}"
IPDASH=$(kubectl get svc kubernetes-dashboard -n kubernetes-dashboard -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "attente que tous les pods soient prets"
kubectl wait --namespace kubernetes-dashboard --for=condition=Ready pod --all --timeout=200s
echo "https://$IPDASH"