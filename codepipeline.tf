resource "aws_codebuild_project" "codebuild" {
  name         = "${var.name}-cicd-test"
  description  = "Build and push Dbocker image to ECR."
  service_role = aws_iam_role.codebuild-role.arn
  tags = var.tags

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true


    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = jsondecode(data.aws_secretsmanager_secret_version.account_id.secret_string)["AWS_ACCOUNT_ID"]
    }
    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = "${jsondecode(data.aws_secretsmanager_secret_version.account_id.secret_string)["AWS_ACCOUNT_ID"]}.dkr.ecr.${var.region}.amazonaws.com/${var.image_repo_name}"
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = var.tag
    }
    environment_variable {
      name = "IMAGE_REPO_NAME"
      value = var.image_repo_name
    }
    environment_variable {
      name = "SERVICE_PORT"
      value = var.port
    }
    environment_variable{
      name = "MEMORY"
      value = var.fargate_memory
    }
    environment_variable{
      name ="ContainerName"
      value = "frozendesserts"
    }

  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("./buildspec-test.yml")
  }


}

resource "aws_codebuild_project" "deploy" {
  name         = "${var.name}-cicd-deploy"
  description  = "Deploy stage for Docker Image"
  service_role = aws_iam_role.codebuild-role.arn
  tags = var.tags
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = jsondecode(data.aws_secretsmanager_secret_version.account_id.secret_string)["AWS_ACCOUNT_ID"]

    }
    environment_variable {
      name  = "ECR_REPOSITORY_URI"
      value = "${jsondecode(data.aws_secretsmanager_secret_version.account_id.secret_string)["AWS_ACCOUNT_ID"]}.dkr.ecr.${var.region}.amazonaws.com/${var.image_repo_name}"
    }

  }
  source {
    type      = "CODEPIPELINE"
    buildspec = file("./buildspec-deploy.yml")
  }
}


resource "aws_codepipeline" "cicd_pipeline" {
  name     = "cicd-frozen-dessert"
  role_arn = aws_iam_role.pipeline-role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_artifacts.id
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["code"]
      configuration = {
        FullRepositoryId     = var.git_repo
        BranchName           = "dev"
        ConnectionArn        = jsondecode(data.aws_secretsmanager_secret_version.codestar_creds.secret_string)["CODESTAR_CREDS"]
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Test"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["code"]
      output_artifacts = ["BuildArtifact"]
      configuration = {
        ProjectName = "${var.name}-cicd-test"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      provider        = "CodeDeployToECS"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["BuildArtifact"]
      configuration = {
        ApplicationName = "${var.name}-service-deploy"
        DeploymentGroupName = "${var.name}-service-deploy-group"
        TaskDefinitionTemplateArtifact = "BuildArtifact"
        TaskDefinitionTemplatePath = "taskdef.json"
        AppSpecTemplateArtifact = "BuildArtifact"
        AppSpecTemplatePath = "appspec.yml"
       }
    }
  }

}