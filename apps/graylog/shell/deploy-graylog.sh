#deploy-graylog.sh
#!/bin/bash

sudo apk add envsubst -f

# kubectl delete namespace graylog
  
  echo "creation namespace"
  kubectl apply -f $APP_PATH/graylog/yaml/graylog-namespace.yaml

echo "creation mongodb"
kubectl apply -f $APP_PATH/graylog/yaml/mongodb.yaml
echo "opensearch bootstrap"
kubectl apply -f $APP_PATH/graylog/yaml/opensearch-daemonset.yaml
echo "opensearch config map"
kubectl apply -f $APP_PATH/graylog/yaml/opensearch-configmap.yaml
echo "creation opensearch"
kubectl apply -f $APP_PATH/graylog/yaml/opensearch-deployment.yaml

echo "creation Graylog"
envsubst < $APP_PATH/graylog/yaml/graylog-deployment.yaml | kubectl apply -f -
