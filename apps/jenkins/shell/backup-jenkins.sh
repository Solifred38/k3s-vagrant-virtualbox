TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
BACKUP_FILE="backup-${TIMESTAMP}.tar.gz"

POD_NAME="jenkins-0"
NAMESPACE="jenkins"
echo "le nom du fichier : "
echo "/vagrant/$BACKUP_FILE"
kubectl exec -n $NAMESPACE $POD_NAME -- tar czf - /var/jenkins_home > /vagrant/$BACKUP_FILE
