# terraform-hetzner

# Setup

* Need to set hetzner api token before you set this up. Easiest to source these into env
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

* Need to source the env like before
* Need to pass hetzner as a command like so: terraform init -var "api_token=$HCLOUD_TOKEN"
* terraform plan -var "api_token=$HCLOUD_TOKEN"
* terraform apply -var "api_token=$HCLOUD_TOKEN"
* scp -i ~/.ssh/hetzner root@<master_ip>:/etc/kubernetes/admin.conf ${HOME}/.kube/config
  * To connect to cluster from local machine
  * Make sure you don't have other cluster information there.


# To install MetalLB

This is optional and would use the ARP or BGP to route traffic. 

This is needed to use ingress controller without nodePort which does not allow 80 or 443.

# Nginx Ingress

So we don't have to fix different kubectl version on local just ssh into master and run command.

* scp -i ~/.ssh/hetzner ./ingress.yml  root@<master_ip>:/root
* scp -i ~/.ssh/hetzner ./services.yml  root@<master_ip>:/root
* ssh -i ~/.ssh/hetzner root@<master_ip> "kubectl apply -f /root/ingress.yml"
* ssh -i ~/.ssh/hetzner root@<master_ip> "kubectl apply -f /root/services.yml"

Note that ingress control i exposed through nodePort rather than LB as shown below


# Useful Test application

kubectl apply -f https://j.hept.io/contour-kuard-example

# Testing getToken

```
echo  "{\"master_ip\": \"95.131.162.104\" }" | ./getToken.sh 
```

# References

https://community.hetzner.com/tutorials/hcloud-install-rancher-single
Writing A file: https://www.digitalocean.com/community/tutorials/how-to-use-cloud-config-for-your-initial-server-setup
https://community.hetzner.com/tutorials/install-kubernetes-cluster
https://www.definit.co.uk/2019/08/lab-guide-kubernetes-load-balancer-and-ingress-with-metallb-and-contour/
https://matthewpalmer.net/kubernetes-app-developer/articles/kubernetes-ingress-guide-nginx-example.html
https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-manifests/
https://kubernetes.github.io/ingress-nginx/deploy/baremetal/

