variable "vpc_name" {
  type        = "string"
  description = "Name of VPC to deploy into"
}

variable "environment" {
  type        = "string"
  description = "Environment of instance"
}

variable "instance_type" {
  type        = "string"
  description = "Type of instance to be used (at least 2G memory)"
  default     = "t2.small"
}

variable "image_filter" {
  type        = "string"
  description = "Search string for instance's image"
}

variable "availability_zone" {
  type        = "string"
  description = "The availability zone where the instance should be started"
}

variable "key_name" {
  type        = "string"
  description = "Name of key to put into key_name for instance"
}

variable "instance_count" {
  type        = "string"
  description = "Number of instances to be deployed"
}

variable "component_name" {
  type        = "string"
  description = "Name of the component that is running this module"
}

variable "zookeeper_quorum" {
  type        = "string"
  description = "Connection string to the Zookeeper quorum"
}

variable "external_ips" {
  type        = "list"
  description = "List of external IPs from which to allow connection to Kafka brokers"
}

variable "internal_ips" {
  type        = "list"
  description = "List of internal IPs from which to allow connection to Kafka brokers"
  default     = []
}

variable "port_ssl" {
  type        = "string"
  description = "Port to use for secure communication with Kafka brokers"
}

variable "port_plain" {
  type        = "string"
  description = "Port to use for plaintext communication with Kafka brokers"
}

variable "volume_size" {
  type        = "string"
  description = "Root volume size for Kafka broker machines"
  default     = 50                                           # EC2 default value for the default instance type
}
