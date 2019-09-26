resource "aws_route53_zone" "puppet_aws" {
  name = "${var.route53_puppet_zone_name}"

  vpc {
    vpc_id = "${aws_vpc.puppet_vpc.id}"
  }

  tags = "${merge(
    var.default_tags,
    map(
      "Name", "${var.route53_puppet_zone_name}"
    ))}"
}

resource "aws_route53_record" "puppetmaster" {
  zone_id = "${aws_route53_zone.puppet_aws.zone_id}"
  name    = "${var.puppetmaster_host_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.puppetmaster.private_ip}"]
}

resource "aws_route53_record" "puppetdb" {
  zone_id = "${aws_route53_zone.puppet_aws.zone_id}"
  name    = "${var.puppetdb_host_name}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.puppetdb.private_ip}"]
}
