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
  description = "Type of instance to be used"
  default     = "t2.micro"
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
  default     = "3"
}

variable "component_name" {
  type        = "string"
  description = "Name of the component that is running this module"
}

variable "service" {
  type        = "string"
  description = "Name of the service which is using Zookeeper"
}

variable "client_port" {
  type        = "string"
  description = "Port where to reach the zookeeper quorum"
  default     = 2181
}
