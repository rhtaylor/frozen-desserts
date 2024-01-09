variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-2"
}

variable "prop_tags" {
  description = "Tags"
  type        = map(string)
  default = {
    Project = "Codebuild Terraform"
    IaC     = "Terraform"
  }
}

variable "codebuild_name" {
  description = "Codebuild project name"
  type        = string
  default     = "strong-mind-codebuild-terraform"
}

variable "codebuild_params" {
  description = "Codebuild parameters"
  type        = map(string)
  default = {
    "NAME"         = "catsafe-docker"
    "GIT_REPO"     = "https://github.com/rhtaylor/catsafecatios"
    "IMAGE"        = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
    "TYPE"         = "LINUX_CONTAINER"
    "COMPUTE_TYPE" = "BUILD_GENERAL1_SMALL"
    "CRED_TYPE"    = "CODEBUILD"
  }
  sensitive = true
}

variable "environment_variables" {
  description = "Environment variables"
  type        = map(string)
  default = {
    "AWS_DEFAULT_REGION" = "us-east-2"
    "IMAGE_REPO_NAME"    = "frozendesserts"
    "IMAGE_TAG"          = "latest"
  }
  sensitive = true
}

variable "name" {
  type        = string
  description = "Name of infrastructure project."
  default     = "frozendesserts"
}

variable "git_repo" {
  type        = string
  description = "Full url of Github Repo to watch for changes"
  default     = "rhtaylor/frozen-desserts"
}

variable "image_repo_name" {
  type        = string
  description = "Name of ECS repo name."
  default     = "frozendesserts"
}

variable "ecs_task_execution_role_name" {
  type        = string
  description = "Name of ECS Task execution role."
  #add later
  default = "value"
}

variable "ecs_auto_scale_role_name" {
  type        = string
  description = "Name of autoscaling group."
  #add later
  default = ""
}

variable "az_count" {
  type        = number
  description = "Number of availability zones in Region."
  default     = 3
}

## REMEMBER TO BUILD ECR REPO URL WITH TAG IN CODE ##

variable "port" {
  type        = number
  description = "Port Docker image exposes to traffic."
  #update to 443 for encryption
  default = 80
}

variable "app_count" {
  type        = number
  description = "Number of Containers to run."
  default     = 3
}

variable "health_check_path" {
  type        = string
  description = "Path to prform health checks through."
  default     = "/"
}

variable "fargate_cpu" {
  type        = string
  description = "CPU to provision for Fargate instances."
  default     = "1024"
}

variable "fargate_memory" {
  type        = string
  description = "Fargate instance memory to provision."
  default     = "2048"
}

variable "main_cidr" {
  type        = string
  description = "CIDR block of main VPC."
  default     = "10.0.0.0/16"
}

variable "docker_tag" {
  type        = string
  description = "Image tag for docker."
  default     = "latest"
}



variable "bucketName" {
  default = ""
  type    = string
}

variable domain_name{
  default = "index.com"
}