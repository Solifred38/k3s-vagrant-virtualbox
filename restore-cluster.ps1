# script de réinitialisation après création des VM avec seulement l'essentiel sans jenkins ni dashboard
#vagrant destroy -f
vagrant up --no-provision
vagrant provision --provision-with cluster-k3s,metallb-install
