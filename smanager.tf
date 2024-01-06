data "aws_secretsmanager_secret" "account" {
  name = "aws-account-id"
}

data "aws_secretsmanager_secret_version" "account_id" {
  secret_id = data.aws_secretsmanager_secret.account.id
}

data "aws_secretsmanager_secret" "codestar" {
  name = "code-star-creds"
}

data "aws_secretsmanager_secret_version" "codestar_creds" {
  secret_id = data.aws_secretsmanager_secret.codestar.id
}



data "aws_secretsmanager_secret" "codestar_arn" {
  arn = nonsensitive("arn:aws:secretsmanager:us-east-2:${jsondecode(data.aws_secretsmanager_secret_version.account_id.secret_string)["AWS_ACCOUNT_ID"]}:secret:code-star-creds-strong-mind")
}