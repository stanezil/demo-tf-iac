resource "tls_private_key" "tls_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_pair" {
  key_name   = "${var.app_name}-generated-key-pair"
  public_key = tls_private_key.tls_key.public_key_openssh
}