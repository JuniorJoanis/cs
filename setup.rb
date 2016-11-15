#!/usr/bin/ruby

require 'net/ssh'
require 'net/scp'

SERVERS = [
  { host: 'dhcp002', user: 'root' },
  { host: 'dhcp003', user: 'root' },
  { host: 'dhcp004', user: 'root' },
  { host: 'dhcp005', user: 'root' },
  { host: 'dhcp006', user: 'root' },
  { host: 'dhcp007', user: 'root' },
  { host: 'dhcp008', user: 'root' },
  { host: 'dhcp009', user: 'root' }
]

BRIDGE_IP = '10.0.3.1' || Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
RELAY_CONF = { 
	cloudscreener_host: "example.net",
	cloudscreener_port: 2525
}

SERVERS.each do |server|
  Net::SSH.start(server[:host], server[:user]) do |session|
  	# Hosts setup
  	session.exec! "echo '#{BRIDGE_IP} #{RELAY_CONF[:cloudscreener_host]}' >> /etc/hosts" 

  	# Nginx install
    puts "- Installing nginx on #{server[:host]} ...\n"
    session.exec! "apt-get -y install nginx"
    session.exec! "rm /var/www/html/*"
    html_page = File.read("nginx/index.html") % { host: server[:host] }
    session.exec! "echo '#{html_page}' > /var/www/html/index.html"
    puts "- Installed nginx on #{server[:host]} \n\n"


    # Postfix install
    puts "- Installing postfix on #{server[:host]} ...\n"

    session.exec! 'debconf-set-selections <<< "postfix postfix/mailname string your.hostname.com"'
		session.exec! 'debconf-set-selections <<< "postfix postfix/main_mailer_type string \'Internet Site\'"'
		session.exec! 'apt-get install -y postfix'

		postfix_main_cf = File.read("postfix/main.cf") % RELAY_CONF
		session.exec! 'echo "' + postfix_main_cf + '" > /etc/postfix/main.cf'
		puts 'echo "' + postfix_main_cf + '" > /etc/postfix/main.cf'
		session.exec! "/etc/init.d/postfix restart"
  end
end