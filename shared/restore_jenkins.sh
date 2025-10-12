#!/bin/bash
set -e

NAMESPACE="jenkins"
LABEL="app.kubernetes.io/name=jenkins"
BACKUP_DIR="$1"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "❌ Répertoire de sauvegarde invalide : $BACKUP_DIR"
  exit 1
fi

POD=$(kubectl get pods -n $NAMESPACE -l $LABEL -o jsonpath="{.items[0].metadata.name}")
echo "🔁 Restauration depuis $BACKUP_DIR..."
echo " nom du pod : $POD"
kubectl cp "$BACKUP_DIR" "$NAMESPACE/$POD:/var/jenkins_home"

echo "🛑 Redémarrage propre..."
kubectl delete pod "$POD" -n $NAMESPACE
