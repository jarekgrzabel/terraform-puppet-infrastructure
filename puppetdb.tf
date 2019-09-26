resource "aws_instance" "puppetdb" {
  ami                         = "${data.aws_ami.centos7.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.jgrzabel.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.puppetsg.id}"]
  subnet_id                   = "${element(random_shuffle.puppet_subnets.result, 0)}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  user_data                   = "${data.template_file.puppetdb_userdata.rendered}"

  root_block_device = {
    volume_type = "gp2"
    volume_size = "20"
  }

  lifecycle {
    ignore_changes = [
      "ami",
    ]
  }

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${upper(var.puppetdb_host_name)}",
      "Description", "Puppet DB server",
      "OS", "Linux",
  ))}"

  volume_tags = "${merge(
    var.default_tags, 
    map(
      "Name", "${upper(var.puppetdb_host_name)}_VOLUME",
  ))}"
}
