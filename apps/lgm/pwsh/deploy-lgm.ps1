# 1. Variables
..\..\..\common\pwsh\set-env-var.ps1

Write-Host "--- Début de l'installation de la Stack LGM sur Minikube avec helm ---" -ForegroundColor Cyan

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install loki-stack grafana/loki-stack --set grafana.enabled=true


kubectl patch svc loki-stack-grafana -p '{"spec": {"type": "NodePort"}}'

Write-Host "--- mot de passe admin"
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($(kubectl get secret loki-stack-grafana -o jsonpath="{.data.admin-password}")))