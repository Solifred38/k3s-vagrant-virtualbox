# --- 1. Initialisation des Variables ---
# On charge d'abord les variables pour que $env:APP_PATH soit connu 
. .\common\pwsh\set-env-var.ps1

Write-Host "🚀 Démarrage du provisionnement Minikube..." -ForegroundColor Cyan

# --- 2. Configuration et Démarrage de Minikube ---
# Basé sur vb.memory = "16000" et vb.cpus = "2" du Vagrantfile [cite: 8, 16]
$MEM_MB = 12000
$CPU_COUNT = 4  

$status = minikube status --format="{{.Host}}"
if ($status -ne "Running") {
    Write-Host "📦 Initialisation de Minikube..."
    minikube start --memory=$MEM_MB --cpus=$CPU_COUNT  --driver=virtualbox --no-vtx-check
}

# --- 3. Activation des Addons ---
minikube addons enable metallb
minikube addons enable dashboard
minikube addons enable metrics-server
minikube addons enable efk

# --- 4. Exécution du Provisionnement (Équivalent server.vm.provision) ---
# Utilisation de virgules explicites pour séparer les entrées du tableau
$provisionSteps = @(
    # @{ Name = "K3s-Config";  Path = "$env:APP_PATH\k3s\pwsh\server-script.ps1" },
    # @{ Name = "Helm";        Path = "$env:APP_PATH\helm\pwsh\deploy-helm.ps1" },
    # @{ Name = "MetalLB";     Path = "$env:APP_PATH\metallb\pwsh\deploy-metallb.ps1" },
    # @{ Name = "Jenkins";     Path = "$env:APP_PATH\jenkins\pwsh\deploy-jenkins.ps1" },
    # @{ Name = "Graylog";     Path = "$env:APP_PATH\graylog\pwsh\deploy-graylog.ps1" },
    # @{ Name = "ELK Stack";   Path = "$env:APP_PATH\elk\pwsh\deploy-elk.ps1" },
    # @{ Name = "Dashboard";   Path = "$env:APP_PATH\dashboard\pwsh\deploy-dashboard.ps1" }
)

foreach ($step in $provisionSteps) {
    $scriptPath = $step.Path
    if (Test-Path $scriptPath) {
        Write-Host "🛠️ Provisionnement : $($step.Name)..." -ForegroundColor Yellow
        # Utilisation de l'opérateur d'appel & pour exécuter le script ps1
        & $scriptPath
    } else {
        Write-Warning "⚠️ Script non trouvé à l'emplacement : $scriptPath"
    }
}

Write-Host "✅ Cluster provisionné !" -ForegroundColor Green