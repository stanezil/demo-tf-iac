variable "AWS_ACCESS_KEY" {
  type      = string
  sensitive = true
}

variable "AWS_SECRET_KEY" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type    = string
  default = "ap-southeast-1"
}

variable "app_name" {
  type    = string
  default = "wiz-vuln-infra-demo"
}

variable "root_user_acct" {
  type    = string
  default = "276097571289"
}

variable "vpc_cidr" {
  type    = string
  default = "20.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["20.0.1.0/24","20.0.2.0/24"]
}

variable "db_ami" {
  type    = string
  default = "ami-00ae2c3d8c3a99b55" #Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
}

variable "ec2_db_instance_type" {
  type    = string
  default = "t2.small"
}

variable "web_ami" {
  type    = string
  default = "ami-00ae2c3d8c3a99b55" #Amazon Linux 2 AMI (HVM) - Kernel 5.10, SSD Volume Type
}

variable "ec2_web_instance_type" {
  type    = string
  default = "t2.small"
}
