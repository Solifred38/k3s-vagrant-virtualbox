POD_NAME="jenkins-0"
NAMESPACE="jenkins"
kubectl exec -n $NAMESPACE $POD_NAME -- tar czf - /var/jenkins_home > /vagrant_shared/backup-jenkins.tar.gz
