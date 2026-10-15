
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${local.name}-api"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.logs.arn

  tags = {
    Name = "${local.name}-api"
  }
}
