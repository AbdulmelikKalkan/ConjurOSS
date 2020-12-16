#Variables
IMAGE_NAME = "centos/7"

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.provider "virtualbox" do |v|
        v.memory = 4096
        v.cpus = 2
    end
    config.vm.define "conjuross" do |conjuross|
        conjuross.vm.box = IMAGE_NAME
        conjuross.vm.network "private_network", ip: "192.168.50.107"
        conjuross.vm.synced_folder ".", "/data", type: "rsync",
		rsync__exclude: [ ".git/", ".editorconfig", ".vagrant", "Vagrantfile"]
        conjuross.vm.hostname = "conjuross"
        conjuross.vm.provider "virtualbox" do |v|
            v.name = "conjuross"
        end
#        conjuross.vm.provision "shell", inline: "echo '192.168.50.107  conjuross' >> /etc/hosts"
#        conjuross.vm.provision "shell", inline: "sudo su - && sed -i -e 's+PasswordAuthentication no+PasswordAuthentication yes+g' /etc/ssh/sshd_config"
#        conjuross.vm.provision "shell", inline: "sudo su - && yum install -y docker"
#        conjuross.vm.provision "shell", inline: "sudo su - && systemctl enable docker"
#        conjuross.vm.provision "shell", inline: "sudo su - && systemctl start docker"
#        conjuross.vm.provision "shell", inline: "sudo su - && curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
#        conjuross.vm.provision "shell", inline: "sudo su - && chmod +x minikube"
#        conjuross.vm.provision "shell", inline: "sudo su - && install minikube /usr/bin/"
#        conjuross.vm.provision "shell", inline: "sudo su - && curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64"
#        conjuross.vm.provision "shell", inline: "sudo su - && install skaffold /usr/bin/"
#        conjuross.vm.provision "shell", inline: "sudo su - && systemctl restart sshd"
    end
    config.vm.provision "shell", inline: <<-SHELL
      echo '192.168.50.107  conjuross' >> /etc/hosts
      sudo sed -i -e 's+PasswordAuthentication no+PasswordAuthentication yes+g' /etc/ssh/sshd_config
      sudo yum install -y git vim net-tools
      sudo yum install -y docker
      sudo systemctl enable docker
      sudo systemctl start docker
      sudo curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      sudo chmod +x minikube
      sudo install minikube /usr/bin/
      sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
      sudo chmod +x /usr/bin/docker-compose
      sudo systemctl restart sshd
      sudo git clone https://github.com/cyberark/conjur-quickstart.git
      mv /data/setup.sh /home/vagrant/conjur-quickstart/
      pwd
    SHELL
end