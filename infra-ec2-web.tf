# DB Instance Init Template
data "template_file" "ec2_web_init" {
  template = file("${path.module}/scripts/web-startup.sh")

    vars = {
      PUBLIC_KEY = "${tls_private_key.tls_key.public_key_openssh}"
      PRIVATE_KEY = "${tls_private_key.tls_key.private_key_openssh}"
    }
}

# EC2 Web
resource "aws_instance" "ec2_web" {
  ami                    = var.web_ami
  instance_type          = var.ec2_web_instance_type
  iam_instance_profile   = aws_iam_instance_profile.ec2_iam_instance_profile.name
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  subnet_id              = element(module.vpc.public_subnets, 0)

  user_data = data.template_file.ec2_web_init.rendered

  tags = {
    Name = "${var.app_name}-web-ec2"
  }
}

# Create EIP
resource "aws_eip" "web_eip" {
  domain = "vpc"
  instance = aws_instance.ec2_web.id
  tags = {
    Name = "${var.app_name}-web-eip"
  }
}

# EC2 Associate EIP
resource "aws_eip_association" "eip_ec2_web_assoc" {
  instance_id   = aws_instance.ec2_web.id
  allocation_id = aws_eip.web_eip.id
}

# Security Group and Rules
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.app_name}_web_sg"
  description = "Allow ports for Web server"
  vpc_id      = module.vpc.vpc_id

  tags = {
    Name = "${var.app_name}-web-sg"
  }
}

resource "aws_security_group_rule" "web_sg_ingress_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow inbound SSH from anywhere"
}

resource "aws_security_group_rule" "web_sg_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow inbound HTTP port from anywhere"
}

# resource "aws_security_group_rule" "web_sg_ingress_httptc" {
#   type              = "ingress"
#   from_port         = 8080
#   to_port           = 8080
#   protocol          = "tcp"
#   cidr_blocks       = ["0.0.0.0/0"]
#   security_group_id = aws_security_group.web_sg.id
#   description       = "Allow inbound HTTP Tomcat port from anywhere"
# }

resource "aws_security_group_rule" "web_sg_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.web_sg.id
  description       = "Allow all output"
}