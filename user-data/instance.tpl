#cloud-config
package_upgrade: true

packages:
    - yum-utils
    - device-mapper-persistent-data
    - lvm2

runcmd:
    - yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    - yum install -y docker-ce docker-ce-cli containerd.io
    - systemctl enable docker
    - systemctl start docker
    - docker run -d --restart=unless-stopped -p 80:80 -p 443:443 rancher/rancher:latest --acme-domain rancher.alexandermorton.co.uk