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
common_path="/vagrant/common"
apps_path="/vagrant/apps"
# 📦 IPs dynamiques
server_ip = "#{network_prefix}.100"


# agents = { "agent1" => "#{network_prefix}.101",
#            "agent2" => "#{network_prefix}.102" }
agents = { "agent1" => "#{network_prefix}.101"}
# agents = {}
# Extra parameters in INSTALL_K3S_EXEC variable because of
# K3s picking up the wrong interface when starting server and agent
# https://github.com/alexellis/k3sup/issues/306

server_script = <<-SHELL
  . #{common_path}/shell/set-env-var.sh
  . #{apps_path}/k3s/shell/server-script.sh   
SHELL

agent_script = <<-SHELL
  . #{common_path}/shell/set-env-var.sh
  . #{apps_path}/k3s/shell/agent-script.sh
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
    . #{apps_path}/helm/shell/deploy-helm.sh
    SHELL

    server.vm.provision "metallb-install", type: "shell", inline: <<-SHELL
    . #{common_path}/shell/set-env-var.sh
    . $APP_PATH/metallb/shell/deploy-metallb.sh
SHELL

server.vm.provision "jenkins", type: "shell", inline: <<-SHELL
    . #{common_path}/shell/set-env-var.sh
    . $APP_PATH/jenkins/shell/deploy-jenkins.sh

  SHELL

server.vm.provision "backup-jenkins", type: "shell", inline: <<-SHELL
    . #{common_path}/shell/set-env-var.sh
    . $APP_PATH/jenkins/shell/backup-jenkins.sh
SHELL
server.vm.provision "graylog", type: "shell", inline: <<-SHELL
    . #{common_path}/shell/set-env-var.sh
    . $APP_PATH/graylog/shell/deploy-graylog.sh
  
SHELL

  server.vm.provision "restore-jenkins", type: "shell", inline: <<-SHELL
  . #{common_path}/shell/set-env-var.sh
    $APP_PATH/jenkins/shell/restore-jenkins.sh
SHELL

server.vm.provision "elk", type: "shell", inline: <<-SHELL
  . #{common_path}/shell/set-env-var.sh
  echo "prefix network dans vagrantfile : $NETWORK_PREFIX"
  . $APP_PATH/elk/shell/deploy-elk.sh

SHELL
server.vm.provision "dashboard", type: "shell", inline: <<-SHELL
  . #{common_path}/shell/set-env-var.sh
  . $APP_PATH/dashboard/shell/deploy-dashboard.sh
SHELL

  end
  agents.each do |agent_name, agent_ip|
    config.vm.define agent_name do |agent|
      agent.vm.network "public_network", ip: agent_ip
      agent.vm.hostname = agent_name
      agent.vm.provider "virtualbox" do |vb|
        vb.memory = "16000"
        vb.cpus = "2"
      end
      agent.vm.provision "cluster-k3s", type: "shell", inline: agent_script
    end
  end
end
