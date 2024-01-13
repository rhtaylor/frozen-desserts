data "aws_caller_identity" "current" {

}
resource "aws_iam_role" "role_to_assume" {
  name = "git-actions-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
       
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "pipeline_service" {

  statement {
    sid = ""
    actions = [
      "logs:*",
      "s3:*",
      "codebuild:*",
      "secretsmanager:*",
      "iam:*",
      "ecr:*",
      "application-autoscaling:*",
      "cloudwatch:*",
      "sts:*",
      "codestar-connections:UseConnection", 
      "codedeploy:*",
      "elasticloadbalancing:*",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "pipeline" {
  name        = "gitactions"
  path        = "/"
  description = "Allow service to run needed tasks."
  policy      = data.aws_iam_policy_document.pipeline_service.json
}
resource "aws_iam_role_policy_attachment" "pipeline_service" {
  role       = aws_iam_role.role_to_assume.name
  policy_arn = aws_iam_policy.pipeline.arn
}

# terraform {
  
#   backend s3{
#     bucket = "terraform-backend-frozen-desserts"
#     key = "smfd-infra"
#     region = "us-east-2"
#   }

#   required_providers {
#     aws = {
#       source  = "hashicorp/aws"
#       version = "~> 5.0"
#     }
#   }

#   required_version = "~> 1.3.2"

# }
# provider "aws" {
#   region = "us-east-2"
  
# }
