resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/frozendesserts"
  retention_in_days = 0
  tags = var.tags
}