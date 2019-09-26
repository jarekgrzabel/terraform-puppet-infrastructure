resource "aws_vpc" "puppet_vpc" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = "${var.vpc_dns}"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "Puppet_VPC"
    ))}"
}

resource "aws_subnet" "subnet_a" {
  vpc_id                  = "${aws_vpc.puppet_vpc.id}"
  cidr_block              = "172.16.1.0/24"
  map_public_ip_on_launch = true

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "Puppet Subnet 172.16.1.0/24"
    ))}"
}

resource "aws_subnet" "subnet_b" {
  vpc_id                  = "${aws_vpc.puppet_vpc.id}"
  cidr_block              = "172.16.2.0/24"
  map_public_ip_on_launch = true

  tags = "${merge(
    var.default_tags,
    map(
      "Name","Puppet Subnet 172.16.2.0/24"
    ))}"
}

resource "aws_internet_gateway" "puppet_vpc_gw" {
  vpc_id = "${aws_vpc.puppet_vpc.id}"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "Puppet_GW"
    ))}"
}

resource "aws_route_table" "default_route_table" {
  vpc_id = "${aws_vpc.puppet_vpc.id}"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "Default Route Table"
    ))}"
}

resource "aws_route_table_association" "subnet_a" {
  subnet_id      = "${aws_subnet.subnet_a.id}"
  route_table_id = "${aws_route_table.default_route_table.id}"
}

resource "aws_route_table_association" "subnet_b" {
  subnet_id      = "${aws_subnet.subnet_b.id}"
  route_table_id = "${aws_route_table.default_route_table.id}"
}

resource "aws_route" "default_route" {
  route_table_id         = "${aws_route_table.default_route_table.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.puppet_vpc_gw.id}"
  depends_on             = ["aws_route_table.default_route_table"]
}
