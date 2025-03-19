resource "aws_db_instance" "rds_mysql" {
  db_name              = "rdsMySQL"
  identifier           = "rds-mysql"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7.44"
  instance_class       = "db.t3.small"
  username             = "myuser"
  password             = "mypassword"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  publicly_accessible  = true
  iam_database_authentication_enabled = true
  vpc_security_group_ids = [aws_security_group.rds_mysql_sg.id]
  db_subnet_group_name = aws_db_subnet_group.rds_mysql_subnet_group.name

  tags = {
    Name = "${var.app_name}-web-ec2"
  }
}

resource "aws_db_subnet_group" "rds_mysql_subnet_group" {
  name       = "${var.app_name}-rds-mysql-subnet-group"
  subnet_ids = module.vpc.public_subnets

  tags = {
    Name = "${var.app_name}-rds-mysql-subnet-group"
  }
}

resource "aws_security_group" "rds_mysql_sg" {
  name        = "${var.app_name}-rds-mysql-sg"
  description = "MySQL public security group"
  vpc_id      = module.vpc.vpc_id

  # Allow inbound traffic on port 3306 for MySQL
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Standard outbound traffic rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-rds-mysql-sg"
  }
}

resource "null_resource" "rds_mysql_setup" {
  depends_on = [aws_db_instance.rds_mysql]

  provisioner "local-exec" {
    on_failure = continue
    command = "python3 ${path.module}/scripts/populate_mysql.py ${aws_db_instance.rds_mysql.address} ${aws_db_instance.rds_mysql.username} ${aws_db_instance.rds_mysql.password} ${aws_db_instance.rds_mysql.db_name}"
  }
}

resource "aws_iam_policy" "rds_iam_policy" {
  name        = "${var.app_name}-rds-iam-policy"
  description = "Policy for RDS IAM authentication"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "rds-db:connect",
        Resource = aws_db_instance.rds_mysql.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "rds_mysql_iam_policy_attachment" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.rds_iam_policy.arn
}