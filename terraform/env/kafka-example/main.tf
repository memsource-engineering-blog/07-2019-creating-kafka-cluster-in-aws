module "hadoop-security-group" {
  source = "../modules/hadoop-security-group/"

  environment = "${var.environment}"
  vpc_name    = "${var.vpc_name}"
}

module "zookeeper" {
  source = "../modules/zookeeper/"

  environment       = "${var.environment}"
  vpc_name          = "${var.vpc_name}"
  availability_zone = "eu-west-1a"
  component_name    = "test"
  service           = "kafka"

  image_filter    = "my-image-name-*"
  instance_type   = "t2.small"
  instance_count  = 3
  key_name        = "${var.master_key}"
}

# IPs allowed to reach Kafka
locals {
  allowed_ips = [
    "XXX.XXX.XXX.XXX/32",
    "YYY.YYY.YYY.YYY/32"
  ]
}

module "kafka" {
  source = "../modules/kafka/"

  environment       = "${var.environment}"
  vpc_name          = "${var.vpc_name}"
  availability_zone = "eu-west-1a"
  zookeeper_quorum  = "${module.zookeeper.zookeeper_quorum}"
  component_name    = "test"

  image_filter    = "my-image-name-*"
  instance_type   = "t2.medium"
  instance_count  = 4
  key_name        = "${var.master_key}"
  external_ips    = "${local.allowed_ips}"
  port_plain      = "9094"
  port_ssl        = "9092"
}
