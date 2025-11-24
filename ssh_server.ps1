# détermination du préfix de l'adresse ip
function Get-NetPrefix {
    # Récupère toutes les adresses IPv4 privées 192.168.x.x
    $ips = Get-NetIPAddress -AddressFamily IPv4 |
           Where-Object { $_.IPAddress -like "192.168.*" }

    if ($ips) {
        # Prend la dernière adresse trouvée
        $lastIp = $ips[-1].IPAddress
        $parts = $lastIp.Split(".")
        "$($parts[0]).$($parts[1]).$($parts[2])"
    }
}
Write-Output "recupération du préfix"
$NETWORK_PREFIX=Get-NetPrefix
Write-Output "adresse ip"
$IP="$NETWORK_PREFIX.100"
Write-Output $IP
Write-Output "ssh vagrant"
ssh vagrant@$IP
