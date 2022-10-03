# Starter guide
First of all, you should have ~ 80 Gb in your hard drive and > 12 Gb of Ram. If you have 8 Gb of Ram, decrease the settings inside the Vagrantfile for every machine to 1024 Mb. The line if you choose the Virtualbox Hypervisor is `vb.customize ["modifyvm", :id, "--memory", 1024]`.

1. Clone the repository
2. Install vagrant and curl
3. Install Packer (optional)
4. Run the prepare.[sh|ps1] script. It checks for preinstalled software and hypervisor settings
5. Run `vagrant up dc` for creating the Domain Controller, a Window 2016 server. After some time (It can take more than 30 minutes), the installation should complete.
6. After than DC you could install in the same way WEF (Windows Events Collector), the Windows 10 host and the Logger.
7. If the virtual machines log into the domain successfully, it means that the installation was successful. If this does not happen, check that the domain controller is active when the other machines are installed

Only Virtualbox has been tested.
Vagrat commands:
Vagrant up `machine name`- Create the Virtual Machine of the selected if it doesn't exist. If it exist, it resume is state/turn it on.
Vagrant up `machine name` --provision - If machine already exist, it re-execute the installation steps (Provision steps starts with `cfg.vm.provision`)
Vagrant up - Starts/Create all the machine
Vagrant -f destroy `machine name` - Destroy a machine 
Vagrant -f destroy - Destroy all the machine (For a complete clean up, clean the .vagrant files) 

