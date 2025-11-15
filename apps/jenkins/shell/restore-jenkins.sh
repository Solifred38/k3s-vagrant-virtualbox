#!/bin/bash

set -euo pipefail

# Variables
POD_NAME="jenkins-0"
NAMESPACE="jenkins"
BACKUP_FILE="/vagrant/backup-jenkins.tar.gz"
TMP_PATH="/tmp/backup-jenkins.tar.gz"
EXTRACT_DIR="/tmp/restore"
TARGET_DIR="/var/jenkins_home"

# Vérification du fichier de backup
[ -f "$BACKUP_FILE" ] || { echo "Backup introuvable : $BACKUP_FILE" >&2; exit 1; }

# Copie du fichier dans le pod
kubectl cp "$BACKUP_FILE" "$NAMESPACE/$POD_NAME:$TMP_PATH" >/dev/null

# Préparation du répertoire temporaire
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c "rm -rf $EXTRACT_DIR && mkdir -p $EXTRACT_DIR"

# Extraction dans le répertoire temporaire
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c \
  "tar xzf $TMP_PATH -C $EXTRACT_DIR --no-same-owner --no-same-permissions 2>/dev/null || true"

# Nettoyage de l'ancien contenu
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c "rm -rf ${TARGET_DIR:?}/*"

# Copie des fichiers restaurés
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c \
  "cp -r $EXTRACT_DIR/var/jenkins_home/. $TARGET_DIR/ 2>/dev/null || true"

# Nettoyage
kubectl exec -n "$NAMESPACE" "$POD_NAME" -- bash -c "rm -rf $TMP_PATH $EXTRACT_DIR"
echo "fin de la mise à jour suppression du pod jenkins pour la relance"
# Redémarrage du pod
kubectl delete pod -n "$NAMESPACE" "$POD_NAME" --wait=true >/dev/null
# attente 10s
echo "attente de relance de jenkins"
sleep 10
