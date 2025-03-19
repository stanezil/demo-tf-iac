# Network Dependencies 
data "aws_availability_zones" "available" {}

# Create VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  
  name                 = "${var.app_name}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = data.aws_availability_zones.available.names
  public_subnets       = var.public_subnet_cidrs
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-vpc"
  }

  public_subnet_tags = {
    Name  = "${var.app_name}-public-subnet"
  }
}