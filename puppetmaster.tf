resource "aws_instance" "puppetmaster" {
  ami                         = "${data.aws_ami.centos7.id}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.jgrzabel.key_name}"
  vpc_security_group_ids      = ["${aws_security_group.puppetsg.id}"]
  subnet_id                   = "${element(random_shuffle.puppet_subnets.result, 0)}"
  associate_public_ip_address = "${var.associate_public_ip_address}"
  iam_instance_profile        = "${aws_iam_instance_profile.puppetmaster_profile.name}"

  user_data = "${data.template_file.puppetmaster_userdata.rendered}"

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
      "Name", "${upper(var.puppetmaster_host_name)}",
      "Description", "Puppet master server",
      "OS", "Linux",
  ))}"

  volume_tags = "${merge(
    var.default_tags, 
    map(
      "Name", "${upper(var.puppetmaster_host_name)}_VOLUME",
  ))}"
}
