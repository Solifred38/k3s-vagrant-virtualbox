# 1. Équivalent de 'get_net_prefix'
# On cherche l'adresse IPv4 qui commence par 192.
$ipAddress = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.*" } | Select-Object -First 1 -ExpandProperty IPAddress

if (-not $ipAddress) {
    Write-Error "Aucune adresse IP commençant par 192 n'a été trouvée."
    return
}

# Extraction du préfixe (les 3 premiers octets)
$octets = $ipAddress.Split('.')
$NETWORK_PREFIX = "$($octets[0]).$($octets[1]).$($octets[2])"

# 2. Export des variables d'environnement (Portée de la session)
$env:KIBANA_IP        = "$NETWORK_PREFIX.210"
$env:ELASTIC_IP       = "$NETWORK_PREFIX.211"
$env:SERVER_IP        = "$NETWORK_PREFIX.100"
$env:APP_PATH         = "C:\Dev\vagrant\alpine\apps" # Adapté pour le format Windows
$env:IPDASH           = "$NETWORK_PREFIX.201"
$env:GRAYLOG_IP       = "$NETWORK_PREFIX.250"
$env:LOADBALANCER_RANGE = "$NETWORK_PREFIX.150-$NETWORK_PREFIX.250"
$env:JENKINS_IP       = "$NETWORK_PREFIX.200"

# Affichage pour vérification
Write-Host "Variables d'environnement initialisées avec le préfixe : $NETWORK_PREFIX" -ForegroundColor Cyan

