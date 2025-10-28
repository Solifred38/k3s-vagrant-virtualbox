minikube image load courses-img
kubectl apply -f namespaces.yml
kubectl apply -f courses-pv.yml
kubectl apply -f courses-pvc.yml
kubectl apply -f courses-deployment.yml
kubectl apply -f courses-svc.yml
