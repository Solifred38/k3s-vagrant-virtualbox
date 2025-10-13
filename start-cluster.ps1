$env:VAGRANT_VAGRANTFILE="Vagrantfile.multinodes"
vagrant destroy -f
vagrant up --no-provision
vagrant provision --provision-with cluster-k3s,helm,metallb-install,metallb-config
