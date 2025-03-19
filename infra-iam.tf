# # Higly privileged admin policy
# resource "aws_iam_policy" "admin_iam_policy" {
#   name        = "${var.app_name}-admin-iam-policy"
#   description = "Higly privileged admin policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "*",
#         ]
#         Effect   = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

# # Highly priviledged policy
# resource "aws_iam_policy" "ec2_iam_policy" {
#   name        = "${var.app_name}-ec2-iam-policy"
#   description = "Higly privileged EC2 policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "ec2:*",
#         ]
#         Effect   = "Allow",
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_policy" "s3_iam_policy" {
#   name        = "${var.app_name}-s3-iam-policy"
#   description = "Higly privileged S3 policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "s3:*",
#         ]
#         Effect   = "Allow",
#         Resource = "arn:aws:s3:::*"
#       }
#     ]
#   })
# }

resource "aws_iam_role" "iam_role" {
  name = "${var.app_name}-iam-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ec2.amazonaws.com"
        },
        "Effect" : "Allow"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${var.root_user_acct}:root"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# resource "aws_iam_policy_attachment" "ec2_iam_policy_attach" {
#   name       = "${var.app_name}-ec2-iam-policy-attach"
#   roles      = [aws_iam_role.iam_role.name]
#   #policy_arn = aws_iam_policy.ec2_iam_policy.arn
#   policy_arn = aws_iam_policy.admin_iam_policy.arn
# }

# resource "aws_iam_policy_attachment" "s3_iam_policy_attach" {
#   name       = "${var.app_name}-s3-iam-policy-attach"
#   roles      = [aws_iam_role.iam_role.name]
#   #policy_arn = aws_iam_policy.s3_iam_policy.arn
#   policy_arn = aws_iam_policy.admin_iam_policy.arn
# }

resource "aws_iam_instance_profile" "ec2_iam_instance_profile" {
  name = "${var.app_name}-ec2-iam-instance-profile"
  role = aws_iam_role.iam_role.name
}