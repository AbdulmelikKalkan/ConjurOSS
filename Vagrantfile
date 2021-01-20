#Variables
IMAGE_NAME = "centos/7"
MASTER_COUNT = 1
NODE_COUND = 1

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.provider "virtualbox" do |v|
        v.memory = 4096
        v.cpus = 2
    end
    config.vm.synced_folder ".", "/data", type: "rsync",
      rsync__exclude: [ ".git/", ".editorconfig", ".vagrant", "Vagrantfile"]
    
    (1..MASTER_COUNT).each do |i|
        config.vm.define "conjuross" do |conjuross|
            conjuross.vm.box = IMAGE_NAME
            conjuross.vm.network "private_network", ip: "192.168.50.#{i + 109}"
            conjuross.vm.hostname = "conjuross-#{i}"
            conjuross.vm.provider "virtualbox" do |v|
                v.name = "conjuross-#{i}"
            end
            (1..MASTER_COUNT).each do |i|
                conjuross.vm.provision "shell",
                  inline: "echo '192.168.50.#{i + 109} conjuross-#{i}' >> /etc/hosts"
            end
            (1..NODE_COUND).each do |i|
                conjuross.vm.provision "shell",
                  inline: "echo '192.168.50.#{i + MASTER_COUNT + 109} conjurnode-#{i}' >> /etc/hosts"
            end
            conjuross.vm.provision "shell", inline: <<-SHELL
                sudo sed -i -e 's+PasswordAuthentication no+PasswordAuthentication yes+g' /etc/ssh/sshd_config
                sudo adduser service01
                sudo echo "Password123" | passwd service01 --stdin 
                sudo yum install -y git vim net-tools
                sudo yum install -y docker
                sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
                sudo yum -y install jq
                sudo yum -y install ansible
                sudo curl -OL https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.rpm
                sudo rpm -i dive_0.9.2_linux_amd64.rpm
                sudo cp /usr/local/bin/dive /usr/bin/
                sudo systemctl enable docker
                sudo systemctl start docker
                sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
                sudo chmod +x minikube
                sudo install minikube /usr/bin/
                sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
                sudo chmod +x /usr/bin/docker-compose
                sudo systemctl restart sshd
                sudo git clone https://github.com/cyberark/conjur-quickstart.git
                cp /data/setup.sh /home/vagrant/conjur-quickstart/
                yes | cp -rf /data/docker-compose.yml /home/vagrant/conjur-quickstart/docker-compose.yml
                cp -R /data/nginx /home/vagrant/conjur-quickstart/
                pwd
                cd conjur-quickstart
                sudo /bin/sh setup.sh
            SHELL
        end
    end
    (1..NODE_COUND).each do |i|
        config.vm.define "conjurnode" do |conjurnode|
            conjurnode.vm.box = IMAGE_NAME
            conjurnode.vm.network "private_network", ip: "192.168.50.#{i + MASTER_COUNT + 109}"
            conjurnode.vm.hostname = "conjurnode-#{i}"
            conjurnode.vm.provider "virtualbox" do |v|
                v.name = "conjurnode-#{i}"
            end
            (1..MASTER_COUNT).each do |i|
                conjurnode.vm.provision "shell",
                  inline: "echo '192.168.50.#{i + 109} conjuross-#{i}' >> /etc/hosts"
            end
            (1..NODE_COUND).each do |i|
                conjurnode.vm.provision "shell",
                  inline: "echo '192.168.50.#{i + MASTER_COUNT + 109} conjurnode-#{i}' >> /etc/hosts"
            end
            conjurnode.vm.provision "shell", inline: <<-SHELL
                sudo sed -i -e 's+PasswordAuthentication no+PasswordAuthentication yes+g' /etc/ssh/sshd_config
                sudo yum install -y git vim net-tools
                sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
                sudo yum -y install jq
                sudo adduser service01
                sudo echo "Password123" | passwd service01 --stdin
                sudo adduser service02
                sudo echo "Password456" | passwd service02 --stdin 
                sudo systemctl restart sshd
            SHELL
        end
    end
end