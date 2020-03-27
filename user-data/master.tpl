#cloud-config
package_upgrade: true
write_files:
  - path: /etc/systemd/system/kubelet.service.d/20-hetzner-cloud.conf
    content: |
      [Service]
      Environment="KUBELET_EXTRA_ARGS=--cloud-provider=external"
  - path: /root/metallb.yml
    content: |
      apiVersion: v1
      kind: ConfigMap
      metadata:
        namespace: metallb
        name: metallb-config
      data:
        config: |
          address-pools:
          - name: default
            protocol: layer2
            addresses:
            - ${FLOATING_IP}/32
  - path: /etc/systemd/system/docker.service.d/00-cgroup-systemd.conf
    content: |
      [Service]
      ExecStart=
      ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock --exec-opt native.cgroupdriver=systemd
  - path: /etc/apt/sources.list.d/docker-and-kubernetes.list
    content: |
      deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable
      deb http://packages.cloud.google.com/apt/ kubernetes-xenial main
  - path: /etc/sysctl.conf
    content: |
      net.bridge.bridge-nf-call-iptables = 1
      net.ipv4.ip_forward = 1
      net.ipv6.conf.default.forwarding = 1
  - path: /root/hetzner-secret.yml
    content: |
      apiVersion: v1
      kind: Secret
      metadata:
        name: hcloud
        namespace: kube-system
      stringData:
        token: "${API_TOKEN}"
        network: "${NETWORK_ID}"
      ---
      apiVersion: v1
      kind: Secret
      metadata:
        name: hcloud-csi
        namespace: kube-system
      stringData:
        token: "${API_TOKEN}"



packages:
package_update: true
package_upgrade: true
runcmd:
    - curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    - curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    - apt-get update
    - apt-get dist-upgrade
    - systemctl daemon-reload
    - modprobe br_netfilter
    - sysctl -p
    - apt-get install -y docker-ce kubeadm kubectl kubelet
    - kubeadm config images pull
    - kubeadm init --pod-network-cidr=${POD_CIDR} --kubernetes-version=v1.18.0 --ignore-preflight-errors=NumCPU --apiserver-cert-extra-sans=10.0.0.10
    - mkdir -p /root/.kube
    - cp /etc/kubernetes/admin.conf /root/.kube/config
    - chown $(id -u):$(id -g) /root/.kube/config
    - export KUBECONFIG=/root/.kube/config
    - kubectl apply -f /root/hetzner-secret.yml
    - rm /root/hetzner-secret.yml
    - kubectl apply -f https://raw.githubusercontent.com/hetznercloud/hcloud-cloud-controller-manager/master/deploy/v1.5.1-networks.yaml
    - kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    - kubectl -n kube-system patch daemonset kube-flannel-ds-amd64 --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'
    - kubectl -n kube-system patch deployment coredns --type json -p '[{"op":"add","path":"/spec/template/spec/tolerations/-","value":{"key":"node.cloudprovider.kubernetes.io/uninitialized","value":"true","effect":"NoSchedule"}}]'
    - kubectl apply -f https://raw.githubusercontent.com/kubernetes/csi-api/release-1.14/pkg/crd/manifests/csidriver.yaml
    - kubectl apply -f https://raw.githubusercontent.com/kubernetes/csi-api/release-1.14/pkg/crd/manifests/csinodeinfo.yaml
    - kubectl apply -f https://raw.githubusercontent.com/hetznercloud/csi-driver/master/deploy/kubernetes/hcloud-csi.yml
    - kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml
    - kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml
    - kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
    - kubectl apply -f /root/metallb.yml
    - ufw allow ssh
    - ufw allow proto tcp from 0.0.0.0/0 to any port 6443
    - ufw allow proto tcp from 10.0.0.0/16 to any port 2379:2380
    - ufw allow proto tcp from 10.0.0.0/16 to any port 10250
    - ufw allow proto tcp from 10.0.0.0/16 to any port 10251
    - ufw allow proto tcp from 10.0.0.0/16 to any port 10252
    - ufw enable
    - reboot