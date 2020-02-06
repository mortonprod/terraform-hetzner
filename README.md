# terraform-hetzner

# Setup

* Need to set hetzner api token before you set this up.
* Also Need to setup aws creds linking to the correct account with the right hosted zone


# Hetzner Node Driver

When you can login to rancher you will need to install Node driver:

* Go to tool drivers
* Select Node driver
* Now fill in the information using reference below
  * Download url: https://github.com/JonasProgrammer/docker-machine-driver-hetzner/releases/download/1.2.2/docker-machine-driver-hetzner_1.2.2_linux_amd64.tar.gz
  * Custom UI Url: https://storage.googleapis.com/hcloud-rancher-v2-ui-driver/component.js
  * Whitelist domain: storage.googleapis.com
* Then go to clusters and create a new one

Once this is completed you will have access to kubectl config which you can use to communicate with the cluster


# References

https://community.hetzner.com/tutorials/hcloud-install-rancher-single

