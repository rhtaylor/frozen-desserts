## CODEPIPELINE ROLE ##

resource "aws_iam_role" "pipeline-role" {
  name = "${var.name}-pipeline-role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "codepipeline-role"
  }
}

data "aws_iam_policy_document" "cicd-pipeline-policies" {
  statement {
    sid       = ""
    actions   = ["codestar-connections:UseConnection"]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    sid       = ""
    actions   = ["cloudwatch:*", "s3:*", "codebuild:*", "ecr:*", "codedeploy:*", "ecs:*", "iam:*", "codedeploy:*", "elasticloadbalancing:*",
       "application-autoscaling:*" ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "cicd-pipeline-policy" {
  name        = "${var.name}-cicd-pipeline-policy"
  path        = "/"
  description = "Pipeline policy"
  policy      = data.aws_iam_policy_document.cicd-pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "cicd-pipeline-attachment" {
  policy_arn = aws_iam_policy.cicd-pipeline-policy.arn
  role       = aws_iam_role.pipeline-role.id
}

## CODEBUILD ##
resource "aws_iam_role" "codebuild-role" {
  name = "${var.name}-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "cicd-build-policies" {
  statement {
    sid       = ""
    actions   = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*", "iam:*", "ecr:*", "ecr:completeLayerUpload", "ecr:InitiateLayerUpload", "ecr:PutImage", "ecr:UploadLayerPart", "codedeploy:*", "ecs:*","elasticloadbalancing:*", 
       "application-autoscaling:*"]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "cicd-build-policy" {
  name        = "${var.name}-cicd-build-policy"
  path        = "/"
  description = "Codebuild policy"
  policy      = data.aws_iam_policy_document.cicd-build-policies.json
}

resource "aws_iam_role_policy_attachment" "cicd-codebuild-attachment" {
  policy_arn = aws_iam_policy.cicd-build-policy.arn
  role       = aws_iam_role.codebuild-role.id
}

resource "aws_iam_role_policy_attachment" "tf-cicd-codebuild-attachment2" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  role       = aws_iam_role.codebuild-role.id
}

## ECS ###

data "aws_iam_policy_document" "ecs_task_execution_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.name}-ecs-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_role.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

## AUTO SCALING ##

resource "aws_iam_role" "ecs_auto_scale_role" {
  name = "${var.name}-ecs-service"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "ecs_service_scaling" {

  statement {
    effect = "Allow"

    actions = [
      "application-autoscaling:*",
      "ecs:*",
      "ecr:*",
      "s3:*",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricAlarm",
      "cloudwatch:DisableAlarmActions",
      "cloudwatch:EnableAlarmActions",
      "sns:*", 
      "codedeploy:*",
      "elasticloadbalancing:*",
      "iam:*"
    ]

    resources = [
      "*"
    ]
  }
}
resource "aws_iam_policy" "ecs_service_scaling" {
  name        = "${var.name}-to-scaling"
  path        = "/"
  description = "Allow ecs service scaling"
  policy      = data.aws_iam_policy_document.ecs_service_scaling.json
}

resource "aws_iam_role_policy_attachment" "ecs_service_scaling" {
  role       = aws_iam_role.ecs_auto_scale_role.name
  policy_arn = aws_iam_policy.ecs_service_scaling.arn
}



data "aws_iam_policy_document" "assume_by_codedeploy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codedeploy" {
  name               = "${var.name}-codedeploy"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_codedeploy.json}"
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    sid    = "AllowLoadBalancingAndECSModifications"
    effect = "Allow"

    actions = [
      "ecs:*",
      "lambda:InvokeFunction",
      "elasticloadbalancing:*",
      "cloudwatch:*",
      "sns:Publish",
      "s3:*",
      "codedeploy:*",
      "iam:*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "AllowPassRole"
    effect = "Allow"

    actions = ["iam:PassRole"]

    resources = [
      "${aws_iam_role.execution_role.arn}",
      "${aws_iam_role.task_role.arn}",
    ]
  }
}

resource "aws_iam_role_policy" "codedeploy" {
  role   = "${aws_iam_role.codedeploy.name}"
  policy = "${data.aws_iam_policy_document.codedeploy.json}"
}


data "aws_iam_policy_document" "assume_by_ecs" {
  statement {
    sid     = "AllowAssumeByEcsTasks"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "execution_role" {
  statement {
    sid    = "AllowECRLogging"
    effect = "Allow"

    actions = [
      "application-autoscaling:*",
      "ecr:*",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "codedeploy:*",
      "elasticloadbalancing:*",
      "iam:*",
      "ecs:*",
      "s3:*"

    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "task_role" {
  statement {
    sid    = "AllowDescribeCluster"
    effect = "Allow"

    actions = ["ecs:DescribeClusters"]

    resources = ["${aws_ecs_cluster.main.arn}"]
  }
}

resource "aws_iam_role" "execution_role" {
  name               = "${var.name}_ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_ecs.json}"
}

resource "aws_iam_role_policy" "execution_role" {
  role   = "${aws_iam_role.execution_role.name}"
  policy = "${data.aws_iam_policy_document.execution_role.json}"
}

resource "aws_iam_role" "task_role" {
  name               = "${var.name}_ecsTaskRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_by_ecs.json}"
}

resource "aws_iam_role_policy" "task_role" {
  role   = "${aws_iam_role.task_role.name}"
  policy = "${data.aws_iam_policy_document.task_role.json}"
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
      "ecs:*",
      "application-autoscaling:*",
      "cloudwatch:*",
      "sts:*",
      "codestar-connections:UseConnection", 
      "codedeploy:*",
      "elasticloadbalancing:*"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "pipeline" {
  name        = "${var.name}-gitactions"
  path        = "/"
  description = "Allow service to run needed tasks."
  policy      = data.aws_iam_policy_document.pipeline_service.json
}
resource "aws_iam_role_policy_attachment" "pipeline_service" {
  role       = aws_iam_role.role_to_assume.name
  policy_arn = aws_iam_policy.pipeline.arn
}
