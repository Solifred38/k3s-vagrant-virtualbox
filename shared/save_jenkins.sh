#!/bin/bash
set -e

NAMESPACE="jenkins"
LABEL="app.kubernetes.io/name=jenkins"
BACKUP_DIR="$HOME/jenkins-backups/$(date +%F_%H-%M)"
mkdir -p "$BACKUP_DIR"

# Récupère le nom du pod Jenkins
POD=$(kubectl get pods -n $NAMESPACE -l $LABEL -o jsonpath="{.items[0].metadata.name}")

if [ -z "$POD" ]; then
  echo "❌ Aucun pod Jenkins trouvé avec le label $LABEL dans le namespace $NAMESPACE"
  exit 1
fi

echo "📦 Sauvegarde du pod $POD..."

# Copie du répertoire JENKINS_HOME
kubectl cp "$NAMESPACE/$POD:/var/jenkins_home" "$BACKUP_DIR"

echo "✅ Sauvegarde terminée dans $BACKUP_DIR"
echo " déplacement de la sauvegarde sur le répertoire partagé vagrant_shared"
mv "$BACKUP_DIR" /vagrant_shared/

