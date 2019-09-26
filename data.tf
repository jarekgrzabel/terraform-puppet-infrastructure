data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ami" "centos7" {
  most_recent = true

  filter {
    name   = "name"
    values = ["*CentOS Linux 7 x86_64 HVM EBS*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["679593333241"] #AWS Marketplace owner ID
}

data "template_file" "puppetmaster_userdata" {
  template = "${file("templates/puppetmaster.tpl")}"

  vars = {
    puppetmaster_host_name = "${var.puppetmaster_host_name}.${var.route53_puppet_zone_name}"
    puppetdb_host_name     = "${var.puppetdb_host_name}.${var.route53_puppet_zone_name}"
  }
}

data "template_file" "puppetdb_userdata" {
  template = "${file("templates/puppetdb.tpl")}"

  vars = {
    puppetmaster_host_name = "${var.puppetmaster_host_name}.${var.route53_puppet_zone_name}"
    puppetdb_host_name     = "${var.puppetdb_host_name}.${var.route53_puppet_zone_name}"
  }
}
