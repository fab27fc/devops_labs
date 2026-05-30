variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  default = "project3-ansible"
}

variable "key_name" {
  description = "AWS Key Pair"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "subnet_id" {
  description = "Subnet ID"
}

variable "my_ip" {
  description = "Public IP for SSH access"
}
