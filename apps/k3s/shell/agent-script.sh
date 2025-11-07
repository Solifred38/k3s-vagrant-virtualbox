#agent-script.sh
    sudo -i
    echo "K3s IP server : $SERVER_IP"
    apk add curl
    if [ -f /usr/local/bin/k3s-agent-uninstall.sh ]; then
      /usr/local/bin/k3s-agent-uninstall.sh
    fi
    export K3S_TOKEN_FILE=/vagrant/token
    export K3S_URL=https://$SERVER_IP:6443
    export INSTALL_K3S_EXEC="--flannel-iface=eth1"
    curl -sfL https://get.k3s.io | sh -
    # récupération du token sur le serveur par scp
