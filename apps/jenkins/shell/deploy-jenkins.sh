#deploy-jenkins.sh
sudo apk add envsubst -f

echo "entree dans installation de jenkins"
#namespace
kubectl apply -f $APP_PATH/jenkins/yaml/jenkins-namespace.yaml
# Volume persistant
mkdir -p /data/jenkins # répertoire local
echo "creation des volumes"
kubectl apply -f $APP_PATH/jenkins/yaml/volume-jenkins.yaml

echo " Pods + Service"
envsubst < $APP_PATH/jenkins/yaml/deployment-jenkins.yaml | kubectl apply -f -

echo "attente que le pod soit pret"
kubectl wait --for=condition=ready pod/jenkins-0 -n jenkins --timeout=200s
echo "✅ Le pod est prêt, vérification de la disponibilité du mot de passe..."
# Boucle d’attente pour que Jenkins ait eu le temps de générer le mot de passe
for i in {1..30}; do
  if kubectl -n jenkins exec jenkins-0 -- test -f /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null; then
    echo "🔑 Fichier trouvé ! Récupération du mot de passe :"
    kubectl -n jenkins exec jenkins-0 -- cat /var/jenkins_home/secrets/initialAdminPassword
    break
  else
    echo "⏳ Fichier pas encore créé... tentative $i/30"
    sleep 10
  fi
done
