variable "ami_id" {
  description = "AMI ID"
  default = "ami-0fc5d935ebf8bc3bc"
}

variable "availability_zone" {
  description = "Availability zone to deploy instance"
  default = "us-east-1b"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "instance_type" {
  description = "Instance type to use"
  default = "t2.micro"
}

variable "key_name" {
  description = "Key pair name"
  default = "sample2"
}