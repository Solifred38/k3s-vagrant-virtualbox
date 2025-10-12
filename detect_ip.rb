require 'rbconfig'

def detect_real_ip_windows
  output = `ipconfig`.force_encoding("IBM437").encode("UTF-8", invalid: :replace, undef: :replace, replace: '')
  lines = output.lines.map(&:strip)

  lines.each do |line|
    # Nettoie les caractères invisibles et accents
    clean = line.encode('ASCII', invalid: :replace, undef: :replace, replace: '').gsub(/\s+/, ' ')
    if clean =~ /Adresse IPv4.*?: (\d+\.\d+\.\d+\.\d+)/
      ip = $1
      return ip if ip.start_with?('192.168.10.') || ip.start_with?('192.168.1.')
    end
  end

  nil
end

def detect_real_ip
  if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
    detect_real_ip_windows
  else
    `ip route get 1.1.1.1`.match(/src (\d+\.\d+\.\d+\.\d+)/)&.captures&.first
  end
end

def network_prefix
  ip = detect_real_ip
  return '192.168.10' if ip&.start_with?('192.168.10.')
  return '192.168.1'  if ip&.start_with?('192.168.1.')
  '192.168.10' # fallback
end

server_ip = "#{network_prefix}.100"
load_balancer_range = "#{network_prefix}.240-#{network_prefix}.250"

puts "IP détectée : #{detect_real_ip}"
puts "Préfixe réseau : #{network_prefix}"
puts "IP serveur : #{server_ip}"
puts "Plage MetalLB : #{load_balancer_range}"