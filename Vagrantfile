# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rbconfig'

# 🔍 Détection IP réelle sur Windows
def detect_real_ip_windows
  output = `ipconfig`.force_encoding("IBM437").encode("UTF-8", invalid: :replace, undef: :replace, replace: '')
  lines = output.lines.map(&:strip)

  lines.each do |line|
    clean = line.encode('ASCII', invalid: :replace, undef: :replace, replace: '').gsub(/\s+/, ' ')
    if clean =~ /Adresse IPv4.*?: (\d+\.\d+\.\d+\.\d+)/
      ip = $1
      return ip if ip.start_with?('192.168.10.') || ip.start_with?('192.168.1.')
    end
  end

  nil
end

# 🔍 Détection IP sur Linux/macOS
def detect_real_ip_unix
  `ip route get 1.1.1.1`.match(/src (\d+\.\d+\.\d+\.\d+)/)&.captures&.first
end

# 🔍 Détection universelle
def detect_real_ip
  if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
    detect_real_ip_windows
  else
    detect_real_ip_unix
  end
end

# 🧠 Déduction du préfixe réseau
def network_prefix
  ip = detect_real_ip
  return '192.168.10' if ip&.start_with?('192.168.10.')
  return '192.168.1'  if ip&.start_with?('192.168.1.')
  '192.168.10' # fallback
end

# quelques variables d'environnement
apps_path="/vagrant/apps"
# 📦 IPs dynamiques
server_ip = "#{network_prefix}.100"
load_balancer_range = "#{network_prefix}.150-#{network_prefix}.250"


agents = { "agent1" => "#{network_prefix}.101",
           "agent2" => "#{network_prefix}.102" }
# agents = { "agent1" => "#{network_prefix}.101"}
# agents = {}
# Extra parameters in INSTALL_K3S_EXEC variable because of
# K3s picking up the wrong interface when starting server and agent
# https://github.com/alexellis/k3sup/issues/306

server_script = <<-SHELL
  export SERVER_IP=#{server_ip}
  sudo chmod +x #{apps_path}/k3s/shell/server-script.sh
  #{apps_path}/k3s/shell/server-script.sh
   
SHELL

agent_script = <<-SHELL
  export SERVER_IP=#{server_ip}
  sudo chmod +x #{apps_path}/k3s/shell/agent-script.sh
  #{apps_path}/k3s/shell/agent-script.sh
SHELL

Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine319"
  # config.vm.box = "k3s-ready.box"
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"
  config.vm.define "server", primary: true do |server|
    server.vm.network "public_network", ip: server_ip
    
    server.vm.hostname = "server"
    server.vm.provider "virtualbox" do |vb|
      vb.memory = "16000"
      vb.cpus = "2"
    end
    server.vm.provision "cluster-k3s", type: "shell", inline: server_script
  
    server.vm.provision "helm", type: "shell", inline: <<-SHELL
    #!/bin/bash
     # installation helm
    echo "installation helm"
    apk add git
    sudo curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh
    SHELL

    server.vm.provision "metallb-install", type: "shell", inline: <<-SHELL
    export APP_PATH=#{apps_path}
    export LOADBALANCER_RANGE=#{load_balancer_range}
    echo "RANGE metallb : $LOADBALANCER_RANGE"
    sudo chmod +x #{apps_path}/metallb/shell/deploy-metallb.sh
    #{apps_path}/metallb/shell/deploy-metallb.sh
SHELL

server.vm.provision "jenkins", type: "shell", inline: <<-SHELL
    export JENKINS_IP=#{network_prefix}.200
    export APP_PATH=#{apps_path}
    sudo chmod +x #{apps_path}/jenkins/shell/deploy-jenkins.sh
    #{apps_path}/jenkins/shell/deploy-jenkins.sh

  SHELL

server.vm.provision "backup-jenkins", type: "shell", inline: <<-SHELL
/vagrant/shell/backup-jenkins.sh
SHELL
server.vm.provision "graylog", type: "shell", inline: <<-SHELL
    export GRAYLOG_IP=#{network_prefix}.250
    export APP_PATH=#{apps_path}
    sudo chmod +x #{apps_path}/graylog/shell/deploy-graylog.sh
    #{apps_path}/graylog/shell/deploy-graylog.sh
  
SHELL

server.vm.provision "restore-jenkins", type: "shell", inline: <<-SHELL
/vagrant/shell/restore-jenkins.sh
echo "attente que le pod soit pret"
kubectl wait --for=condition=ready pod/jenkins-0 -n jenkins --timeout=200s
echo "jenkins est pret"
SHELL

server.vm.provision "elk", type: "shell", inline: <<-SHELL
sudo chmod +x #{apps_path}/elk/shell/deploy-elk.sh
export NETWORK_PREFIX=#{network_prefix}
echo "prefix network dans vagrantfile : $NETWORK_PREFIX"
#{apps_path}/elk/shell/deploy-elk.sh

SHELL
server.vm.provision "dashboard", type: "shell", inline: <<-SHELL

# initialisation si nécessaire
if kubectl get namespace kubernetes-dashboard &> /dev/null; then
        kubectl delete namespace kubernetes-dashboard
  fi
echo "installation dashboard"

echo "creation namespace"
kubectl create namespace kubernetes-dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
echo "creation d'un compte admin"

kubectl apply -f - <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl -n kubernetes-dashboard create token admin-user

echo "\n"
# des fois çà marche pas il faut patcher
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard \
  -p '{"spec": {"type": "LoadBalancer"}}'

kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard \
  -p '{"spec": {"loadBalancerIP": "#{network_prefix}.201"}}'

echo "adresse du dashboard: "
IPDASH=$(kubectl get svc kubernetes-dashboard -n kubernetes-dashboard \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "attente que tous les pods soient prets"
kubectl wait --namespace kubernetes-dashboard \
  --for=condition=Ready pod \
  --all --timeout=200s

echo "https://${IPDASH}"

SHELL

  end
  agents.each do |agent_name, agent_ip|
    config.vm.define agent_name do |agent|
      agent.vm.network "public_network", ip: agent_ip
      agent.vm.hostname = agent_name
      agent.vm.provider "virtualbox" do |vb|
        vb.memory = "8000"
        vb.cpus = "2"
      end
      agent.vm.provision "cluster-k3s", type: "shell", inline: agent_script
    end
  end
end
