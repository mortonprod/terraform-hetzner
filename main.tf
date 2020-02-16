provider "hcloud" {

}

provider "aws" {
  region = "${var.aws_region}"
}

resource "hcloud_network" "network" {
  name = "kubernetes"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_floating_ip" "floating_ip" {
  type = "ipv4"
}

resource "hcloud_network_subnet" "network_subnet" {
  network_id = "${hcloud_network.network.id}"
  type = "server"
  network_zone = "${var.hetzner_region}"
  ip_range   = "10.0.0.0/24"
}

resource "hcloud_ssh_key" "ssh_key" {
  name = "${var.name}"
  public_key = "${file("~/.ssh/${var.ssh_key_name}")}"
}

data "template_file" "file_worker" {
    vars = {
      FLOATING_IP = "${hcloud_floating_ip.floating_ip.ip_address}"
      API_TOKEN   = "${var.api_token}"
      NETWORK_TOKEN   = "${hcloud_network.network.id}"
    }
    template = "${file("${path.module}/user-data/worker.tpl")}"
}

data "template_file" "file_master" {
    vars = {
      FLOATING_IP = "${hcloud_floating_ip.floating_ip.ip_address}"
    }
    template = "${file("${path.module}/user-data/master.tpl")}"
}

resource "hcloud_server" "server_master" {
  name = "${var.name}-master"
  image = "${var.image}"
  server_type = "${var.type}"
  ssh_keys = ["${hcloud_ssh_key.ssh_key.id}"]
  user_data = "${data.template_file.file_master.rendered}"
}

resource "hcloud_server" "server_worker" {
  count = "${var.num_workers}"
  name = "${var.name}-worker"
  image = "${var.image}"
  server_type = "${var.type}"
  ssh_keys = ["${hcloud_ssh_key.ssh_key.id}"]
  user_data = "${data.template_file.file_worker.rendered}"
}

data "aws_route53_zone" "route53_zone" {
  name = "${var.root_domain}"
}

resource "aws_route53_record" "example" {
  name    = "${var.name}"
  type    = "A"
  ttl = 30
  zone_id = "${data.aws_route53_zone.route53_zone.id}"
  records = ["${hcloud_server.server_master.ipv4_address}"]
}