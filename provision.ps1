# Chemin vers ton Vagrantfile
$VagrantfilePath = ".\Vagrantfile.multinodes"
$env:VAGRANT_VAGRANTFILE=$VagrantfilePath
# Lire le contenu
$content = Get-Content $VagrantfilePath -Raw

# Expression régulière élargie pour capturer tous les inline shell provisioners
$pattern = '(?m)\bvm\.provision\s+["'']([^"'']+)["'']\s*,\s*type:\s*["'']shell["'']\s*,\s*inline:\s*(<<-?\w+|["''][^"'']*["'']|\w+)'

# Extraire les noms des provisioners
$matches = [regex]::Matches($content, $pattern)
$provisioners = $matches | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique

if ($provisioners.Count -eq 0) {
    Write-Host "Aucun provisioner shell trouvé dans le fichier $VagrantfilePath." -ForegroundColor Red
    exit
}

# Affichage des options
Write-Host "`nProvisioners détectés :" -ForegroundColor Cyan
for ($i = 0; $i -lt $provisioners.Count; $i++) {
    Write-Host "$($i+1). $($provisioners[$i])"
}

# Sélection utilisateur
$selection = Read-Host "`nEntrez les numéros des provisioners à utiliser (séparés par des virgules)"
$indices = $selection -split "," | ForEach-Object { ($_ -as [int]) - 1 } | Where-Object { $_ -ge 0 -and $_ -lt $provisioners.Count }

if ($indices.Count -eq 0) {
    Write-Host "Sélection invalide." -ForegroundColor Red
    exit
}

# Construction de la commande
$selectedProvisioners = $indices | ForEach-Object { $provisioners[$_] }
$provisionerList = $selectedProvisioners -join ","
$command = "vagrant provision --provision-with $provisionerList"

Write-Host "`nCommande générée :" -ForegroundColor Green
Write-Host $command

# Exécution ?
$run = Read-Host "`nSouhaitez-vous exécuter cette commande ? (o/n)"
if ($run -eq "o") {
    Invoke-Expression $command
}