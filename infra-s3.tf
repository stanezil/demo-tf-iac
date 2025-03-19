# S3 Bucket and Policy
resource "aws_s3_bucket" "email_bucket" {
  bucket        = "${var.app_name}-email-bucket-demo"
  force_destroy = true

  tags = {
    Name = "${var.app_name}-email-bucket-demo"
  }
}

resource "aws_s3_object" "email_bucket_object" {
  bucket = aws_s3_bucket.email_bucket.id
  key    = "fake-emails.txt"
  source = "${path.module}/scripts/fake-emails.txt"
}

resource "aws_s3_bucket_public_access_block" "email_bucket_block" {
  bucket = aws_s3_bucket.email_bucket.id

  block_public_acls   = false
  block_public_policy = false
}