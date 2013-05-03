# http://vagrantup.com/v1/docs/vagrantfile.html

Vagrant::Config.run do |config|
  config.vm.box = "drupal"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  #config.vm.box = 'centos-62-64-puppet'
  #config.vm.box_url = 'http://packages.vstone.eu/vagrant-boxes/centos/6.2/centos-6.2-64bit-puppet-vbox.4.1.12.box'
  config.vm.define :project do |project_config|
      project_config.vm.host_name = "drupal-dev"

      config.vm.network :hostonly, "33.33.33.15"
      config.vm.customize ["modifyvm", :id, "--memory", 1024]
      config.vm.share_folder "v-root", "/home/vagrant/code", ".", :nfs => true

      config.vm.provision :puppet do |puppet|
          puppet.manifests_path = "manifests"
          puppet.module_path = "modules"
          puppet.manifest_file  = "app.pp"
     end
  end
end
