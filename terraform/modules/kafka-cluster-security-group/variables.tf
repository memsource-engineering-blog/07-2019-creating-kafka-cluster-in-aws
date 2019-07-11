variable "vpc_name" {
  type        = "string"
  description = "Name of VPC to deploy into"
}

variable "environment" {
  type        = "string"
  description = "Environment of instance"
}

variable "ssh_ips" {
  type        = "list"
  description = "List of IPs to whitelist in security groups for ssh"
}
