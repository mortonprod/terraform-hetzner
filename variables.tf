variable "name" {
  default = "services"
}
variable "aws_region" {
  default = "eu-west-2"
}

variable "type_master" {
  default = "cx21"
}

variable "type_worker" {
  default = "cx21"
}

variable "pod_cidr" {
  description = "This must match the cloud controller manager cidr range which is internal"
  default = "10.244.0.0/16"
}

variable "image" {
  # default = "centos-7"
  default = "ubuntu-18.04"
}

variable "ssh_key_name" {
  default = "hetzner.pub"
}

variable "root_domain" {
  default = "alexandermorton.co.uk"
}

variable "subnet_region" {
  default = "eu-central"
}

variable "ip_region" {
  default = "nbg1"
}

variable "num_workers" {
  default = 1
}

variable "api_token" {
}