$env:VAGRANT_VAGRANTFILE="Vagrantfile.multinodes"
vagrant destroy -f
vagrant up --no-provision
.\provision.ps1