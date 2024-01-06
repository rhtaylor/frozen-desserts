resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "${var.name}-artifacts-bucket"

  tags = {
    Name = "artifacts-bucket"
  }
}