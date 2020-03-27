output "join_command" {
  value = "${data.external.get_join_command.result["join_command"]}"
}

output "scp_config_command" {
  value = "scp -i ~/.ssh/hetzner root@${hcloud_server.server_master.ipv4_address}:/etc/kubernetes/admin.conf ~/.kube/config"
}

output "scp_ingress" {
  value = "scp -i ~/.ssh/hetzner ./ingress.yml  root@${hcloud_server.server_master.ipv4_address}:/root"
}

output "scp_services" {
  value = "scp -i ~/.ssh/hetzner ./services.yml  root@${hcloud_server.server_master.ipv4_address}:/root"
}

output "ssh_ingress" {
  value = "ssh -i ~/.ssh/hetzner root@${hcloud_server.server_master.ipv4_address} \"kubectl apply -f /root/ingress.yml\""
}

output "ssh_services" {
  value = "ssh -i ~/.ssh/hetzner root@${hcloud_server.server_master.ipv4_address} \"kubectl apply -f /root/services.yml\""
}