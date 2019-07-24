data "aws_vpc" "vpc" {
  tags = {
    Name = "${var.vpc_name}"
  }
}

resource "aws_security_group" "kafka_cluster" {
  name        = "kafka-cluster-security-group"
  description = "Allow kafka_cluster traffic"
  vpc_id      = "${data.aws_vpc.vpc.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "kafka-cluster-security-group"
  }
}

resource "aws_security_group_rule" "allow_kafka_cluster_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["${var.ssh_ips}"]

  security_group_id = "${aws_security_group.kafka_cluster.id}"
}

resource "aws_security_group_rule" "allow_kafka_cluster_self_ping" {
  type      = "ingress"
  from_port = 8
  to_port   = 0
  protocol  = "icmp"
  self      = true

  security_group_id = "${aws_security_group.kafka_cluster.id}"
}
