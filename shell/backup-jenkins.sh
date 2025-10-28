TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="backup-${TIMESTAMP}.tar.gz"

POD_NAME="jenkins-0"
NAMESPACE="jenkins"
echo "le nom du fichier : "
echo "/vagrant_shared/$BACKUP_FILE"
kubectl exec -n $NAMESPACE $POD_NAME -- tar czf - /var/jenkins_home > /vagrant_shared/$BACKUP_FILE
