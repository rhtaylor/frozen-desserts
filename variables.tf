variable "region" {
  description = "Region"
  type        = string
  default     = "us-east-2"
}

variable "prop_tags" {
  description = "Tags"
  type        = map(string)
  default = {
    Project = "Strong Mind Terraform"
    IaC     = "Terraform"
  }
}

variable "codebuild_name" {
  description = "Codebuild project name"
  type        = string
  default     = "strong-mind-codebuild-terraform"
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


variable "az_count" {
  type        = number
  description = "Number of availability zones in Region."
  default     = 3
}

variable "port" {
  type        = number
  description = "Port Docker image exposes to traffic."
  #update to 443 for encryption
  default = "3000"
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


variable tag {
  default = "latest"
}

variable tags {
  default = {
    name = "frozen desserts"
    company = "Strong Mind"
  }
}