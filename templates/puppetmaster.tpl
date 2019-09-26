#!/bin/bash
sleep 60
hostnamectl set-hostname ${puppetmaster_host_name}
systemctl stop iptables
systemctl disable iptables

yum install "https://yum.puppet.com/puppet6/puppet6-release-el-7.noarch.rpm" -y
yum install "https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm" -y

yum install vim-enhanced bash-completion nc puppetserver jq awscli -y

/opt/puppetlabs/bin/puppet module install theforeman-puppet
/opt/puppetlabs/bin/puppet module install camptocamp-systemd
/opt/puppetlabs/bin/puppet module install puppetlabs-puppetdb

cat > puppet_master_install.pp <<EOF
class { 'puppet': 
  server => true,
  server_foreman => false,
  dns_alt_names => [ "${puppetmaster_host_name}" ],
  server_external_nodes => '',
  autosign_entries => [ "*.puppet.aws" ],
  server_certname => "${puppetmaster_host_name}",
  client_certname => "${puppetmaster_host_name}",
  ca_server => "${puppetmaster_host_name}",
  server_ca_allow_sans => true,
  puppetmaster => "${puppetmaster_host_name}",
  server_cipher_suites => 
  [
    "TLS_RSA_WITH_AES_256_CBC_SHA256",
    "TLS_RSA_WITH_AES_256_CBC_SHA",
    "TLS_RSA_WITH_AES_128_CBC_SHA256",
    "TLS_RSA_WITH_AES_128_CBC_SHA",
  ],
}
EOF
/opt/puppetlabs/bin/puppet apply puppet_master_install.pp

while true
do
  nc -zv ${puppetdb_host_name} 8081
  if [ $? -eq 0 ]
    then
      break
  fi
  sleep 5
done

cat > puppet_db_setup.pp <<EOF
class { 'puppetdb::master::config': 
  puppetdb_server => '${puppetdb_host_name}',
  enable_reports => true,
  
}
EOF

/opt/puppetlabs/bin/puppet apply puppet_db_setup.pp


/opt/puppetlabs/bin/puppet module install puppet-hiera
cat > puppet_hiera.pp <<EOF
class { 'hiera': 
  eyaml => true,
  hiera_version   =>  '5',
  hiera5_defaults =>  {"datadir" => "/etc/puppetlabs/code/hieradata/%%{environment}", "data_hash" => "yaml_data"},
  hierarchy       =>  [
                        {"name" =>  "Nodes yaml", "paths" =>  ['nodes/%%{::trusted.certname}.yaml', 'nodes/%%{::osfamily}.yaml']},
                        {"name" =>  "Default yaml file", "path" =>  "common.yaml"},
                        {"name" =>  "Encrypted data", "lookup_key" => "eyaml_lookup_key", "paths" => [ 'common.eyaml' ]},
                                          ],
}
EOF
/opt/puppetlabs/bin/puppet apply puppet_hiera.pp

/opt/puppetlabs/bin/puppet module install puppet-r10k
cat > puppet_r10k.pp <<EOF
class { 'r10k':
  sources => {
        'puppet' => {
          'remote'  => 'git@github.com:dogjarek/puppet-main.git',
          'basedir' => '/etc/puppetlabs/code/environments',
        },
        'hiera' => {
          'remote'  => 'git@github.com:dogjarek/puppet-hiera.git',
          'basedir' => '/etc/puppetlabs/code/hieradata',
        }
  }
}

class {'r10k::webhook::config':
  enable_ssl     => false,
  protected      => false,
  use_mcollective => false,
}
class { 'r10k::webhook':
  use_mcollective => false,
  user            => 'root',
  group           => '0',
  require         => Class['r10k::webhook::config'],
}
EOF
/opt/puppetlabs/bin/puppet apply puppet_r10k.pp

aws ssm get-parameter --name puppet_github_ssh_private_key --with-decryption --region=eu-west-2 |jq -r ".Parameter.Value" > /etc/puppetlabs/r10k/r10k.rsa
chmod 600 /etc/puppetlabs/r10k/r10k.rsa
chown puppet:puppet /etc/puppetlabs/r10k/r10k.rsa

cat > /root/.ssh/config <<EOF
Host github.com
IdentityFile /etc/puppetlabs/r10k/r10k.rsa

Host *
    StrictHostKeyChecking no

EOF

r10k deploy environment production --color -p -v debug1

/opt/puppetlabs/bin/puppet agent --test