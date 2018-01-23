# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'
require 'yaml'

## Read VM settings from "Vagrant.yml". These settings can be overridden by
## values in an optional "Vagrant.local.yml" file, which is ignored by git.

dir = File.dirname(File.expand_path(__FILE__))
settings = YAML::load_file("#{dir}/Vagrant.yml")
if File.exists?("#{dir}/Vagrant.local.yml")
    local = YAML::load_file("#{dir}/Vagrant.local.yml")
    settings["vb"].merge!(local["vb"])
end

################################################################################

# Require vagrant 1.8.1 or higher
Vagrant.require_version ">= 1.8.1"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    config.vm.box = "ubuntu/trusty64"
    config.vm.hostname = settings["vb"]["hostname"]
    config.vm.network settings["vb"]["network"], bridge: settings["vb"]["bridge"], type: "dhcp"

    ## VM hardware settings
    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", settings["vb"]["memory"]]
        vb.customize ["modifyvm", :id, "--cpus", settings["vb"]["cpus"]]
        vb.customize ["modifyvm", :id, "--natnet1", settings["vb"]["subnet"]]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    end

    ## Synced folders
    config.vm.synced_folder ".", "/vagrant", type: settings["vb"]["sync"]

    ## VM Provisioning

    # Disable IPv6
    config.vm.provision "shell", inline: "sysctl -w net.ipv6.conf.all.disable_ipv6=1", run: "always"
    config.vm.provision "shell", inline: "sysctl -w net.ipv6.conf.default.disable_ipv6=1", run: "always"

    config.vm.provision "shell", inline: <<-SHELL
        export DEBIAN_FRONTEND=noninteractive
		apt-get update
        apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" apache2 avahi-daemon libapache2-mod-php5 mysql-server php5-mysql
        rm -rf /var/www/html
		ln -sf /vagrant/docroot /var/www/html
        echo -e "<Directory \"/var/www/html\">\nAllowOverride All\n</Directory>" > /etc/apache2/conf-available/htaccess-override.conf
        a2enconf htaccess-override
        a2enmod rewrite
        service apache2 restart
        mysql -e "create database wordpress;"
        mysql -e "grant all on wordpress.* to wordpress@'%' identified by 'wordpress';"
        echo -e "<?php\ndefine('DB_NAME','wordpress');\ndefine('DB_USER','wordpress');\ndefine('DB_PASSWORD','wordpress');" > /var/www/html/wp-config.local.php
    SHELL

    # Add defined SSH public key to vagrant user's authorized_keys
    if settings["vb"]["sshkey"]
        config.vm.provision "shell", inline: "echo \"#{settings['vb']['sshkey']}\" >> ~vagrant/.ssh/authorized_keys"
    end
end
