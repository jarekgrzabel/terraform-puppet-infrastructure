resource "aws_security_group" "puppetsg" {
  name        = "puppetsg"
  description = "Allow traffic to puppet"
  vpc_id      = "${aws_vpc.puppet_vpc.id}"

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "Puppet Security Group"
    ))}"
}

resource "aws_security_group_rule" "allow_puppet_8140" {
  type                     = "ingress"
  from_port                = 8140
  to_port                  = 8140
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.puppetsg.id}"
  source_security_group_id = "${aws_security_group.puppetsg.id}"
}

resource "aws_security_group_rule" "allow_puppetdb_8081" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8081
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.puppetsg.id}"
  source_security_group_id = "${aws_security_group.puppetsg.id}"
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.puppetsg.id}"
  cidr_blocks       = ["${var.trusted_ips}"]
}

resource "aws_security_group_rule" "in_allow_all" {
  type              = "ingress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = "${aws_security_group.puppetsg.id}"

  cidr_blocks = [
    "${aws_instance.puppetdb.public_ip}/32",
    "${aws_instance.puppetmaster.public_ip}/32",
    "${aws_instance.puppetdb.private_ip}/32",
    "${aws_instance.puppetmaster.private_ip}/32",
  ]
}

resource "aws_security_group_rule" "out_allow_all" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = "${aws_security_group.puppetsg.id}"
  cidr_blocks       = ["0.0.0.0/0"]
}
