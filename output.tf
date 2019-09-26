output "puppet_master_ip" {
  value = "${aws_instance.puppetmaster.public_ip}"
}

output "puppet_db_ip" {
  value = "${aws_instance.puppetdb.public_ip}"
}
