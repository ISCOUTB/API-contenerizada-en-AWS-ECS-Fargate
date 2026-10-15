variable "aws_region" {
  description = "Región de AWS para el bucket y los recursos del bootstrap."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Nombre globalmente único del bucket para el estado remoto."
  type        = string
}

variable "github_actions_role_name" {
  description = "Nombre del rol asumido por los workflows de GitHub Actions."
  type        = string
  default     = "domusnet-terraform-github-actions"
}

variable "project_name" {
  description = "Nombre de proyecto usado en etiquetas y permisos IAM."
  type        = string
  default     = "domusnet-api"
}

variable "environment" {
  description = "Entorno asociado a los recursos del bootstrap."
  type        = string
  default     = "dev"
}

variable "team_name" {
  description = "Equipo propietario de los recursos."
  type        = string
  default     = "DOMUSNET"
}
