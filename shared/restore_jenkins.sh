#!/bin/bash

# Variables
POD_NAME="jenkins-0"
NAMESPACE="jenkins"
BACKUP_FILE="/vagrant_shared/backup-jenkins.tar.gz"
TMP_PATH="/tmp/backup-jenkins.tar.gz"
TARGET_DIR="/var/jenkins_home"

# Vérification du fichier de backup
if [ ! -f "$BACKUP_FILE" ]; then
  echo "❌ Fichier de backup introuvable : $BACKUP_FILE"
  exit 1
fi

# Copie du fichier dans le pod
echo "📦 Copie du fichier de backup dans le pod..."
kubectl cp "$BACKUP_FILE" "$NAMESPACE/$POD_NAME:$TMP_PATH"

# Nettoyage de l'ancien contenu
echo "🧹 Nettoyage de $TARGET_DIR..."
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c "rm -rf ${TARGET_DIR:?}/*"

# Extraction du backup
echo "📂 Extraction du backup..."
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c "tar xzf $TMP_PATH -C /"

# Suppression du fichier temporaire
echo "🧽 Suppression du fichier temporaire..."
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- rm "$TMP_PATH"

# Redémarrage du pod
echo "🔄 Redémarrage du pod Jenkins..."
kubectl delete pod -n "$NAMESPACE" "$POD_NAME" --wait=true

echo "✅ Restauration terminée et pod redémarré."