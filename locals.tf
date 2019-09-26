locals {
  puppet_subnets = "${list(aws_subnet.subnet_a.id, aws_subnet.subnet_b.id)}"
}
