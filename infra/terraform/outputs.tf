output "api_url" {
  description = "URL pública HTTP de la API."
  value       = "http://${aws_lb.api.dns_name}"
}

output "ecr_repository_url" {
  description = "URL del repositorio ECR de la aplicación."
  value       = aws_ecr_repository.api.repository_url
}

output "ecs_cluster_name" {
  description = "Nombre del clúster ECS."
  value       = aws_ecs_cluster.main.name
}

output "ecs_service_name" {
  description = "Nombre del servicio ECS."
  value       = aws_ecs_service.api.name
}

output "ecs_task_definition_family" {
  description = "Familia de la definición de tarea de ECS."
  value       = aws_ecs_task_definition.api.family
}

output "log_group_name" {
  description = "Grupo de CloudWatch Logs de la API."
  value       = aws_cloudwatch_log_group.api.name
}
