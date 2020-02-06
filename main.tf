provider "hcloud" {

}

provider "aws" {
  region = "${var.aws_region}"
}

resource "hcloud_ssh_key" "ssh_key" {
  name = "${var.name}"
  public_key = "${file("~/.ssh/${var.ssh_key_name}")}"
}

data "template_file" "file" {
    template = "${file("${path.module}/user-data/instance.tpl")}"
}

resource "hcloud_server" "server" {
  name = "${var.name}"
  image = "${var.image}"
  server_type = "${var.type}"
  ssh_keys = ["${hcloud_ssh_key.ssh_key.id}"]
  user_data = "${data.template_file.file.rendered}"
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