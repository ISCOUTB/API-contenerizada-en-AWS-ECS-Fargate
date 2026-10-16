resource "aws_security_group" "alb" {
  name        = "${local.name}-alb"
  description = "Entrada HTTP publica al balanceador"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP publico hacia el ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #checkov:skip=CKV_AWS_260:La demo educativa necesita acceso HTTP publico al ALB y no dispone de dominio ni certificado TLS.

  tags = {
    Name = "${local.name}-alb"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb_to_tasks" {
  security_group_id            = aws_security_group.alb.id
  description                  = "Trafico del ALB hacia el puerto de la API"
  referenced_security_group_id = aws_security_group.tasks.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "tasks" {
  name        = "${local.name}-tasks"
  description = "Entrada a tareas solo desde el ALB"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Salida HTTPS para ECR y CloudWatch"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS UDP hacia el resolver de la VPC (ECR y CloudWatch)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS TCP hacia el resolver de la VPC (respuestas extensas)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-tasks"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tasks_from_alb" {
  security_group_id            = aws_security_group.tasks.id
  description                  = "Trafico de la API solo desde el ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}
