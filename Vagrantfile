Vagrant.configure("2") do |config|

  config.vm.hostname = "ubuntu-dev"
  config.vm.synced_folder "/Users/blueprint/kevinjiang-bpoms", "/kevinjiang-bpoms", docker_consistency: "cached"
  config.vm.network :forwarded_port, host: 5432, guest: 5432
  
  config.vm.define "docker"  do |docker|

    # docker.vm.network :private_network, type: "dhcp", docker_network__internal: true
    # docker.vm.network :private_network,
    #     ip: "172.20.128.2", netmask: "16"
    # docker.vm.network :private_network, type: "dhcp", subnet: "2a02:6b8:b010:9020:1::/80"

    ############################################################
    # Provider for Docker on Intel or ARM (aarch64)
    ############################################################
    docker.vm.provider "docker" do |d|
      d.image = "kjiang95/vagrant-provider:ubuntu"
      d.remains_running = true
      d.has_ssh = true
      d.privileged = true
      d.volumes = ["/sys/fs/cgroup:/sys/fs/cgroup:rw"]
      d.create_args = ["--cgroupns=host"]
      # Uncomment to force arm64 for testing images on Intel
      # docker.create_args = ["--platform=linux/arm64", "--cgroupns=host"]     
    end

  end

end
