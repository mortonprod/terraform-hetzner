variable "name" {
  default = "kubernetes"
}
variable "aws_region" {
  default = "eu-west-2"
}

variable "type" {
  default = "cx11"
}

variable "image" {
  default = "centos-7"
}

variable "ssh_key_name" {
  default = "hetzner"
}

variable "root_domain" {
  default = "alexandermorton.co.uk"
}

variable "hetzner_region" {
  default = "eu-central"
}

variable "num_workers" {
  default = 1
}

variable "api_token" {
}