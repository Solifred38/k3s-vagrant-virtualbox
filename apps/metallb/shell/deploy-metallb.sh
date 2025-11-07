#deploy-metallb.sh
#!/bin/bash
sudo apk add envsubst -f
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.8/config/manifests/metallb-native.yaml
# attente de création des ressources dans metallb-system
echo "attente de création des ressources dans metallb-system"
sleep 10
echo "attente que les pods soient ready"
kubectl wait --namespace metallb-system \
  --for=condition=Ready pod \
  --all --timeout=200s
kubectl get pods -n metallb-system -o wide
# configuration 
echo "configuration du loadBalancer"
kubectl -n metallb-system patch daemonset speaker \
  --type='json' \
  -p='[{"op": "remove", "path": "/spec/template/spec/nodeSelector/speaker"}]'|| true
echo "echelle des adresses : $LOADBALANCER_RANGE"
envsubst < $APP_PATH/metallb/yaml/metallb-template.yaml | kubectl apply -f -

