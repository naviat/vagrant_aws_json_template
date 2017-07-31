# -*- mode: ruby -:u:*-
# vi: set ft=ruby :

require 'json'
require 'pp'

aws_config = (JSON.parse(File.read("vagrant.config.json")))

#get this file from a developer or any (other?) reliable person
aws_credentials = (JSON.parse(File.read("aws_private.config.json")))

Vagrant.configure("2") do |config|

    #use dummy box to fake vagrant and make it think we have a real box.
    config.vm.box = "dummy"
    config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"

    #iterate over all instances and apply settings
    ip_hosts=[]
    aws_config['instances'].each do |instance|
        instance_name   = instance[0]
        instance_value = instance[1]

        if instance_value['disabled'] == true
              next
        end

        #ip - host for etc/hosts
        ip_hosts.push(instance_value['private_ip'] + ' ' + instance_name)

        #common shared files for all machines of the cluster
        config.vm.synced_folder "common", "/usr/share/vagrant/common", create: true, type: "rsync"
        config.vm.provision :shell, :path => 'common/provision.sh'

        #main ec2 instances config for each machine.
        config.vm.define instance_name do |instance_config|
            ec2_tags = instance_value['tags']

            #provisioning
            instance_value['provisioners'].each do |path|
                instance_config.vm.provision :shell, :path => path, :args => instance_value['args']
            end

            #shared folders
            instance_value['shares'].each do | vagrantDir, localDir |
                instance_config.vm.synced_folder localDir, vagrantDir, create: true, type: "rsync"
            end

            #aws specific ec2 config
            instance_config.vm.provider :aws do |ec2, override|
                ec2.access_key_id = aws_credentials['access_key']
                ec2.secret_access_key = aws_credentials['secret_key']
                ec2.keypair_name = aws_credentials['keypair_name']
                ec2.region = aws_config['region']
                #ec2.availability_zone = aws_config['region']+aws_config['availability_zone']
                ec2.subnet_id = aws_config['subnet_id']
				#use internal ip for building the vpn tunnel - not documented
		        #plugin parameter
                #https://github.com/mitchellh/vagrant-aws/issues/294
                #ec2.ssh_host_attribute = :private_ip_address
                ec2.security_groups = aws_config['security_groups']
                ec2.ami = instance_value['ami_id']
                ec2.instance_type = instance_value['instance_type']

                if instance_value['private_ip'] != ''
                  ec2.private_ip_address=instance_value['private_ip']
                end

                if instance_value['elb'] != ''
                  ec2.elb = instance_value['elb']
                end

                ec2.tags = {
                    'Name' => instance_name,
                    #'Role' => ec2_tags['Role']
                }
                override.ssh.username = aws_config['ssh_username']
                override.ssh.private_key_path = aws_credentials['ssh_private_key_path']
            end
        end
    end

    #add a ip-hostname list to create a hosts file for VPC
    output = File.open( "common/etc_hosts", "w" )
    output << ip_hosts.join("\n")
    output.close

    # if you have installed this trigger scripts, may run
    if Vagrant.has_plugin?("vagrant-triggers")
        config.trigger.before :destroy do
           #run  'vagrant ssh -c "sudo /usr/share/vagrant/provision/decomission.sh"'
        end
        config.trigger.after [:up, :resume, :reload], :stdout => true do
          info "Starting all the fancy services for you..."
          #@machine.communicate.sudo("/bin/bash /usr/share/vagrant/startup/startup.sh")
          info "...ur ready to parteeey!"
        end
    end
end
