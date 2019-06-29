output "zookeeper_quorum" {
  value = "${join(",", aws_instance.zookeeper.*.private_dns)}:2181"
}

output "zookeeper_instance_ids" {
  value       = "${aws_instance.zookeeper.*.id}"
  description = "ID of zookeeper instances"
}

output "zookeeper_instance_count" {
  value       = "${var.instance_count}"
  description = "Count of zookeeper instances"
}
