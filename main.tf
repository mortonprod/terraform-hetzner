provider "hcloud" {

}

provider "aws" {
  region = "${var.aws_region}"
}

resource "hcloud_network" "network" {
  name = "kubernetes"
  ip_range = "10.0.0.0/16"
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
    template = "${file("${path.module}/user-data/worker.tpl")}"
}

data "template_file" "file_master" {
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
  records = ["${hcloud_server.server.ipv4_address}"]
}