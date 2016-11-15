#!/bin/ruby

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

SERVERS.each do |server|
	Net::SSH.start(server[:host], user[:user]) do |session|
		session.exec! "apt-get -y install nginx"
		session.exec! "rm /var/www/html/*"
		html_page = File.read("nginx/index.html") % { host: server[:host] }
		session.exec! "echo '#{html_page}' /var/www/html/index.html"
	end
end