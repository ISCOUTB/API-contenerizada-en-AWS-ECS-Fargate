output "state_bucket_name" {
  description = "Bucket S3 creado para el estado remoto."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "github_actions_role_arn" {
  description = "ARN que debe guardarse en la variable AWS_ROLE_ARN del repositorio."
  value       = aws_iam_role.github_actions.arn
}

output "github_oidc_provider_arn" {
  description = "ARN del proveedor OIDC de GitHub."
  value       = aws_iam_openid_connect_provider.github.arn
}
