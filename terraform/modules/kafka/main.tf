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

resource "aws_instance" "kafka" {
  ami           = "${data.aws_ami.image_latest.id}"
  instance_type = "${var.instance_type}"
  subnet_id     = "${tolist(data.aws_subnet_ids.public_subnets.ids)[0]}"
  key_name      = "${var.key_name}"

  vpc_security_group_ids      = ["${data.aws_security_group.kafka_cluster.id}", "${aws_security_group.kafka.id}"]
  associate_public_ip_address = true
  availability_zone           = "${var.availability_zone}"

  tags {
    Name        = "${var.component_name}-${format("kafka-broker-%03d", count.index + 1)}"
    Role        = "kafka-${var.component_name}"
    Environment = "${var.environment}"
    Component   = "${var.component_name}"
    Service     = "kafka"
  }

  root_block_device {
    volume_size = "${var.volume_size}"
  }

  depends_on = ["aws_security_group.kafka"]
  count      = "${var.instance_count}"
}

######################
# Security Groups
######################

resource "aws_security_group" "kafka" {
  name        = "${var.component_name}-kafka-security-group"
  description = "Allow kafka ${var.component_name} traffic"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  tags {
    Name = "${var.component_name}-kafka-security-group"
  }
}

resource "aws_security_group_rule" "allow_kafka_port_peers" {
  type      = "ingress"
  from_port = "${var.port_plain}"
  to_port   = "${var.port_plain}"
  protocol  = "tcp"
  self      = true

  security_group_id = "${aws_security_group.kafka.id}"
}

resource "aws_security_group_rule" "allow_kafka_port_local_kafka_cluster_sg" {
  type                     = "ingress"
  from_port                = "${var.port_plain}"
  to_port                  = "${var.port_plain}"
  protocol                 = "tcp"
  source_security_group_id = "${data.aws_security_group.kafka_cluster.id}"

  security_group_id = "${aws_security_group.kafka.id}"
}

resource "aws_security_group_rule" "allow_kafka_port_local_ips" {
  type        = "ingress"
  from_port   = "${var.port_plain}"
  to_port     = "${var.port_plain}"
  protocol    = "tcp"
  cidr_blocks = ["${var.internal_ips}"]

  security_group_id = "${aws_security_group.kafka.id}"

  count = "${length(var.internal_ips) > 0 ? 1 : 0}" // create the rule only if at least one local ip is specified
}

resource "aws_security_group_rule" "allow_kafka_port_external" {
  type        = "ingress"
  from_port   = "${var.port_ssl}"
  to_port     = "${var.port_ssl}"
  protocol    = "tcp"
  cidr_blocks = ["${var.external_ips}"]

  security_group_id = "${aws_security_group.kafka.id}"
}

resource "aws_security_group_rule" "allow_kafka_port_ssl_haddop_sg" {
  type                     = "ingress"
  from_port                = "${var.port_ssl}"
  to_port                  = "${var.port_ssl}"
  protocol                 = "tcp"
  source_security_group_id = "${data.aws_security_group.kafka_cluster.id}"

  security_group_id = "${aws_security_group.kafka.id}"
}
