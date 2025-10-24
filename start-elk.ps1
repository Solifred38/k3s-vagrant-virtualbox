$env:VAGRANT_VAGRANTFILE="Vagrantfile.multinodes"
vagrant up --provision --provision-with cluster-k3s,metallb-install,elk
