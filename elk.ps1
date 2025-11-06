# script de réinitialisation après création des VM avec seulement l'essentiel sans jenkins ni dashboard
$env:VAGRANT_VAGRANTFILE="vagrantfile.multinodes"
#vagrant destroy -f
vagrant up --no-provision
vagrant provision --provision-with cluster-k3s,metallb-install,elk
