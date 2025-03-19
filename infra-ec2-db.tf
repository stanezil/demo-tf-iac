# DB Instance Init Template
data "template_file" "ec2_db_init" {
  template = file("${path.module}/scripts/db-startup.sh")
}

# EC2 DB Instance
resource "aws_instance" "ec2_db" {
  ami                    = var.db_ami
  instance_type          = var.ec2_db_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_iam_instance_profile.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  subnet_id              = element(module.vpc.public_subnets, 0)

  user_data = data.template_file.ec2_db_init.rendered

  tags = {
    Name = "${var.app_name}-db-ec2"
  }
}

# Create EIP
resource "aws_eip" "db_eip" {
  domain = "vpc"
  instance = aws_instance.ec2_db.id
  tags = {
    Name = "${var.app_name}-db-eip"
  }
}

# EC2 Associate EIP
resource "aws_eip_association" "eip_ec2_db_assoc" {
  instance_id   = aws_instance.ec2_db.id
  allocation_id = aws_eip.db_eip.id
}

# Security Group and Rules
resource "aws_security_group" "db_sg" {
  name_prefix = "${var.app_name}_db_sg"
  description = "Allow ports for DB server"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.app_name}-db-sg"
  }
}

resource "aws_security_group_rule" "db_sg_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow inbound SSH from anywhere"
}

resource "aws_security_group_rule" "db_sg_ingress_mongo" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow inbound MongoDB port from anywhere"
}

resource "aws_security_group_rule" "db_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow all output"
}