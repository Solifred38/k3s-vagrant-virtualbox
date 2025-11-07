#server-script.sh
sudo -i
    apk update
    apk add bash curl coreutils sudo openrc iproute2 e2fsprogs tcpdump wget tar
 
    if [ -f /usr/local/bin/k3s-uninstall.sh ]; then
      /usr/local/bin/k3s-uninstall.sh
    fi
    export INSTALL_K3S_EXEC="--bind-address=$SERVER_IP --node-external-ip=$SERVER_IP --flannel-iface=eth1"
    echo "install k3 parameters : $INSTALL_K3S_EXEC"
    curl -sfL https://get.k3s.io | sh -
    while [ ! -f /var/lib/rancher/k3s/server/token ]; do
      echo "Sleeping for 2 seconds to wait for k3s to start"
      sleep 2
    done
    sudo chown vagrant:vagrant /etc/rancher/k3s/k3s.yaml
    echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> /etc/profile
    
    sudo cp /var/lib/rancher/k3s/server/token /vagrant
    sudo chmod +r /etc/rancher/k3s/k3s.yaml

    sudo cp /etc/rancher/k3s/k3s.yaml /vagrant
    # petit alias 
    echo "alias k=kubectl" >> /home/vagrant/.bashrc
    echo 'if [ -f ~/.bashrc ]; then source ~/.bashrc; fi' >> /home/vagrant/.profile
    chown vagrant:vagrant /home/vagrant/.bashrc /home/vagrant/.profile