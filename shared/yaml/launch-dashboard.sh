kubectl apply -f admin-user.yaml
kubectl -n kube-system create token admin-user
kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443

