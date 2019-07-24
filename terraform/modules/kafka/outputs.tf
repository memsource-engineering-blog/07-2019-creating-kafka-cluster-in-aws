output "kafka_servers_local" {
  value = "${join(":9094,", aws_instance.kafka.*.private_dns)}:9094"
}

output "kafka_servers_external" {
  value = "${join(":9092,", aws_instance.kafka.*.public_dns)}:9092"
}

output "kafka_instance_ids" {
  value       = "${aws_instance.kafka.*.id}"
  description = "ID of kafka instances"
}

output "kafka_instance_count" {
  value       = "${var.instance_count}"
  description = "Count of kafka instances"
}
