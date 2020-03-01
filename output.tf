output "join_command" {
  value = "${data.external.get_join_command.result["join_command"]}"
}

output "scp_config_command" {
  value = "scp -i ~/.ssh/hetzner root@${hcloud_server.server_master.ipv4_address}:/etc/kubernetes/admin.conf ~/.kube/config"
}