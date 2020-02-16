#cloud-config
package_upgrade: true
write_files:
  - path:  /etc/network/interfaces.d/60-floating-ip.cfg
    content: |
      auto eth0:1
      iface eth0:1 inet static
        address ${FLOATING_IP}
        netmask 32
  - path: /etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf
    content: |
      [Service]
      Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external"
  - path: /etc/systemd/system/docker.service.d/00-cgroup-systemd.conf
    content: |
      [Service]
      ExecStart=
      ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd
  - path: /etc/apt/sources.list.d/docker-and-kubernetes.list
    content: |
      deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable
      deb http://packages.cloud.google.com/apt/ kubernetes-xenial main
  - path: /etc/sysctl.conf
    content: |
      net.bridge.bridge-nf-call-iptables = 1
      net.ipv4.ip_forward = 1
      net.ipv6.conf.default.forwarding = 1
      EOF
      all$ sysctl -p

packages:

runcmd:
    - apt-get update
    - apt-get dist-upgrade
    - systemctl restart networking.service
    - systemctl daemon-reload
    - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    - curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    - apt-get install docker-ce kubeadm kubectl kubelet
    - reboot