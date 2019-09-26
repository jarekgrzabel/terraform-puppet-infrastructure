variable "cidr_block" {
  default = "172.16.0.0/16"
}

variable "vpc_dns" {
  default = true
}

variable "default_tags" {
  type = "map"

  default = {
    Owner        = "Jarek Grzabel"
    "Managed by" = "terraform"
  }
}

variable "puppetmaster_host_name" {
  default = "puppetmaster"
}

variable "puppetdb_host_name" {
  default = "puppetdb"
}

variable "instance_type" {
  default = "t3.xlarge"
}

variable "trusted_ips" {
  type = "list"

  default = [
    "0.0.0.0/0", # never do it... only for demo purposes!
  ]
}

variable "associate_public_ip_address" {
  default = true
}

variable "route53_puppet_zone_name" {
  default = "puppet.aws"
}
