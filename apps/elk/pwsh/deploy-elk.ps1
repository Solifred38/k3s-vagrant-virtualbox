# 1. Variables
..\..\..\common\pwsh\set-env-var.ps1

Write-Host "--- Début de l'installation de la Stack ELK sur Minikube ---" -ForegroundColor Cyan

# 2. Définition des chemins
$KIBANA_PATH = "$($env:APP_PATH)\elk\yaml"

# 3. Installation de l'Elastic Operator (ECK)
# Note : Indispensable si vous utilisez l'opérateur Elastic pour gérer la stack
Write-Host "Installation des CRD et de l'Elastic Operator..."
kubectl apply -f https://download.elastic.co/downloads/eck/2.15.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.15.0/operator.yaml

# 4. Déploiement de la Stack (Elasticsearch, Kibana, Logstash)
Write-Host "📦 Préparation et déploiement de elk-stack.yaml avec IP $($env:KIBANA_IP)..."
$stackYamlContent = Get-Content "$KIBANA_PATH\elk-stack-minikube.yaml" -Raw
$ExecutionContext.InvokeCommand.ExpandString($stackYamlContent) | kubectl apply -f -

# Changement du namespace par défaut pour les commandes suivantes
kubectl config set-context --current --namespace elastic-system

# 5. Attente de la disponibilité des Pods
Write-Host "⏳ Attente que les pods soient Ready (cela peut prendre plusieurs minutes)..."
kubectl wait --for=condition=ready pod -l common.k8s.elastic.co/type=elasticsearch -n elastic-system --timeout=600s
kubectl wait --for=condition=ready pod -l common.k8s.elastic.co/type=kibana -n elastic-system --timeout=600s

# Logstash n'est pas toujours géré par l'opérateur de la même façon, on utilise un sélecteur générique
kubectl wait --for=condition=ready pod -l app=logstash -n elastic-system --timeout=300s

Write-Host "🎉 Stack ELK déployée ! Lancement de l'import des Dashboards..." -ForegroundColor Green

# 6. Import des Dashboards via les Jobs Metricbeat et Filebeat
kubectl apply -f "$KIBANA_PATH\filebeat-import-dashboard-job.yaml"
kubectl apply -f "$KIBANA_PATH\metricbeat-import-dashboard-job.yaml"

# 7. Accès à Kibana (Spécifique Minikube)
Write-Host "--------------------------------------------------------"
Write-Host "Pour accéder à Kibana sous Windows :" -ForegroundColor Yellow
Write-Host "1. Exécutez : minikube service kibana -n elastic-system"
Write-Host "2. Ou si vous avez configuré MetalLB, exécutez : minikube tunnel"
Write-Host "--------------------------------------------------------"