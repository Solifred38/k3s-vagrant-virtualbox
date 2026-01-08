# 1. Variables
..\..\..\common\pwsh\set-env-var.ps1

# 2. Préparation du répertoire dans Minikube
Write-Host "Initialisation du dossier dans Minikube..." -ForegroundColor Cyan
minikube ssh "sudo mkdir -p /data/jenkins && sudo chmod 777 /data/jenkins"

# 3. Application du Namespace et du Volume
kubectl apply -f "$($env:APP_PATH)\jenkins\yaml\jenkins-namespace.yaml"
kubectl apply -f "$($env:APP_PATH)\jenkins\yaml\volume-jenkins-minikube.yaml"

# 4. Déploiement + Service (avec substitution de variables)
Write-Host "Déploiement de Jenkins et du Service..."
$files = @("deployment-jenkins-minikube.yaml")

foreach ($file in $files) {
    $path = "$($env:APP_PATH)\jenkins\yaml\$file"
    $content = Get-Content $path -Raw
    $ExecutionContext.InvokeCommand.ExpandString($content) | kubectl apply -f -
}

# 5. Attente et récupération du mot de passe (comme précédemment)
Write-Host "Attente du démarrage..."
kubectl wait --for=condition=ready pod -l app=jenkins -n jenkins --timeout=200s

# ... (votre boucle de récupération du mot de passe)

Write-Host "✅ Le pod est prêt, vérification du mot de passe..." -ForegroundColor Green

# 6. Boucle d'attente pour le mot de passe initial
$passwordPath = "/var/jenkins_home/secrets/initialAdminPassword"

for ($i = 1; $i -le 30; $i++) {
    # On teste l'existence du fichier à l'intérieur du conteneur
    $testFile = kubectl -n jenkins exec jenkins-0 -- sh -c "test -f $passwordPath && echo 'exists'" 2>$null
    
    if ($testFile -eq "exists") {
        Write-Host "🔑 Fichier trouvé ! Récupération du mot de passe :" -ForegroundColor Yellow
        kubectl -n jenkins exec jenkins-0 -- cat $passwordPath
        break
    }
    else {
        Write-Host "⏳ Fichier pas encore créé... tentative $i/30"
        Start-Sleep -Seconds 10
    }
}