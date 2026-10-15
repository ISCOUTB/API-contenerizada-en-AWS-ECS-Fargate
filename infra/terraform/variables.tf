variable "aws_region" {
  description = "Región de AWS donde se despliega la infraestructura."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefijo identificador del proyecto."
  type        = string
  default     = "domusnet-api"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name solo puede contener letras minúsculas, números y guiones."
  }
}

variable "environment" {
  description = "Entorno de despliegue."
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "environment solo puede contener letras minúsculas, números y guiones."
  }
}

variable "team_name" {
  description = "Equipo propietario de los recursos."
  type        = string
  default     = "DOMUSNET"
}

variable "app_port" {
  description = "Puerto HTTP de la aplicación dentro del contenedor."
  type        = number
  default     = 8000
}

variable "desired_count" {
  description = "Cantidad deseada de tareas Fargate."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_count >= 1
    error_message = "desired_count debe ser al menos 1."
  }
}

variable "cpu" {
  description = "CPU Fargate en unidades de CPU; 256 es el mínimo del taller."
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memoria Fargate en MiB; 512 es el mínimo para 256 CPU."
  type        = number
  default     = 512
}

variable "log_retention_days" {
  description = "Retención de los logs de CloudWatch."
  type        = number
  default     = 365
}

variable "image_tag" {
  description = "Etiqueta inicial de la imagen para la definición de tarea."
  type        = string
  default     = "latest"
}
