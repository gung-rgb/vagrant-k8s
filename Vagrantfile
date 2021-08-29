image = "ubuntu/focal64"
Vagrant.configure("2") do |config|
  config.vm.provider :virtualbox do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision :shell, name: "prepare", privileged: true, path: "common-setup.sh"
  


  config.vm.define :master do |master|
    master.vm.box = image
    master.vm.hostname = "master"
    master.vm.network :private_network, ip: "172.16.50.10"
    master.vm.provision :shell, privileged: false, path: "provision-master-node.sh"
  end

  %w{worker1 worker2}.each_with_index do |name, i|
    config.vm.define name do |worker|
      worker.vm.box = image
      worker.vm.hostname = name
      worker.vm.network :private_network, ip: "172.16.50.#{i + 11}"

      #provision-worker-node
      worker.vm.provision :shell, privileged: false, inline: <<-SHELL
        sudo /vagrant/join.sh
        echo 'Environment="KUBELET_EXTRA_ARGS=--node-ip=172.16.50.#{i + 11}"' | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
        sudo systemctl daemon-reload
        sudo systemctl restart kubelet
    SHELL
    end
  end

   # install_multicast
  config.vm.provision "shell", inline: <<-SHELL
    apt-get -qq install -y avahi-daemon libnss-mdns
  SHELL

end



