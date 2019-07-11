data "aws_ami" "image_latest" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${var.image_filter}"]
  }
}

data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.vpc_name}"
  }
}

data "aws_subnet_ids" "public_subnets" {
  vpc_id = "${data.aws_vpc.vpc.id}"

  tags = {
    Name = "public_*"
  }
}

data "aws_security_group" "kafka_cluster" {
  tags = {
    Name = "kafka-cluster-security-group"
  }
}

resource "aws_instance" "zookeeper" {
  ami           = "${data.aws_ami.image_latest.id}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${tolist(data.aws_subnet_ids.public_subnets.ids)[2]}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids      = ["${data.aws_security_group.kafka_cluster.id}", "${aws_security_group.zookeeper.id}"]
  associate_public_ip_address = true
  availability_zone           = "${var.availability_zone}"

  tags = {
    Name        = "${var.component_name}-${var.service}-${format("zookeeper-%03d", count.index + 1)}"
    Role        = "zookeeper-${var.service}-${var.component_name}"
    Environment = "${var.environment}"
    Component   = "${var.component_name}"
    Service     = "${var.service}"
  }

  depends_on = ["aws_security_group.zookeeper"]
  count      = "${var.instance_count}"
}

######################
# Security Groups
######################

resource "aws_security_group" "zookeeper" {
  name        = "${var.component_name}-${var.service}-zookeeper-security-group"
  description = "Allow Zookeeper traffic for ${var.component_name}-${var.service}"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags = {
    Name = "${var.component_name}-${var.service}-zookeeper-security-group"
  }
}

resource "aws_security_group_rule" "allow_zookeeper_quorum" {
  type                     = "ingress"
  from_port                = "${var.client_port}"
  to_port                  = "${var.client_port}"
  protocol                 = "tcp"
  source_security_group_id = "${data.aws_security_group.kafka_cluster.id}"

  security_group_id = "${aws_security_group.zookeeper.id}"
}

resource "aws_security_group_rule" "allow_zookeeper_peers" {
  type      = "ingress"
  from_port = 2888
  to_port   = 2888
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.zookeeper.id}"
}

resource "aws_security_group_rule" "allow_zookeeper_leader_election" {
  type      = "ingress"
  from_port = 3888
  to_port   = 3888
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.zookeeper.id}"
}
