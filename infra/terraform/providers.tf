provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Team        = var.team_name
      Project     = var.project_name
      Environment = var.environment
    }
  }
}
