#!/bin/bash
sleep 60
hostnamectl set-hostname ${puppetdb_host_name}
systemctl stop iptables
systemctl disable iptables
yum install "https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm" -y
yum install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm" -y
yum install vim-enhanced bash-completion nc puppetdb -y

# Wait for puppet master to start...
while true
do
  nc -zv ${puppetmaster_host_name} 8140
  if [ $? -eq 0 ]
    then
      break
  fi
  sleep 5
done

/opt/puppetlabs/bin/puppet config set server ${puppetmaster_host_name} --section=main
/opt/puppetlabs/bin/puppet agent --test
/opt/puppetlabs/bin/puppetdb ssl-setup
/opt/puppetlabs/bin/puppet module install camptocamp-systemd
/opt/puppetlabs/bin/puppet module install puppetlabs-puppetdb


cat > puppet_db_setup.pp <<EOF
class { 'puppetdb':
    listen_address => '${puppetdb_host_name}',
    manage_firewall => false,
    cipher_suites => "TLS_RSA_WITH_AES_256_CBC_SHA256, TLS_RSA_WITH_AES_256_CBC_SHA, TLS_RSA_WITH_AES_128_CBC_SHA256, TLS_RSA_WITH_AES_128_CBC_SHA",
}
EOF

/opt/puppetlabs/bin/puppet apply puppet_db_setup.pp

systemctl start puppet
