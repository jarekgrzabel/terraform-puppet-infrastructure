resource "random_shuffle" "puppet_subnets" {
  input        = ["${local.puppet_subnets}"]
  result_count = 1
}
