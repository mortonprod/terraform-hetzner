# terraform-hetzner

# Setup

* Need to set hetzner api token before you set this up.
* Also Need to setup aws creds linking to the correct account with the right hosted zone


# Hetzner Node Driver Rancher

When you can login to rancher you will need to install Node driver:

* Go to tool drivers
* Select Node driver
* Now fill in the information using reference below
  * Download url: https://github.com/JonasProgrammer/docker-machine-driver-hetzner/releases/download/1.2.2/docker-machine-driver-hetzner_1.2.2_linux_amd64.tar.gz
  * Custom UI Url: https://storage.googleapis.com/hcloud-rancher-v2-ui-driver/component.js
  * Whitelist domain: storage.googleapis.com
* Then go to clusters and create a new one

Once this is completed you will have access to kubectl config which you can use to communicate with the cluster

# Hetzner Kube setup

Run

* scp root@<master_ip>:/etc/kubernetes/admin.conf ${HOME}/.kube/config


# References

https://community.hetzner.com/tutorials/hcloud-install-rancher-single
Writing A file: https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup
https://community.hetzner.com/tutorials/install-kubernetes-cluster

