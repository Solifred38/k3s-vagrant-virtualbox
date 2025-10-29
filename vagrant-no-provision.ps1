$env:VAGRANT_VAGRANTFILE="vagrantfile.multinodes"
vagrant destroy -f
vagrant up --no-provision
