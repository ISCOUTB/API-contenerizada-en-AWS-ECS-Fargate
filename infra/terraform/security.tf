#checkov:skip=CKV_AWS_260:El acceso HTTP público termina en el ALB, que es el único punto de entrada del taller.
resource "aws_security_group" "alb" {
  name        = "${local.name}-alb"
  description = "Entrada HTTP publica al balanceador"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP público hacia el ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "Tráfico del ALB solo hacia el puerto de la API"
    from_port       = var.app_port
    to_port         = var.app_port
    protocol        = "tcp"
    security_groups = [aws_security_group.tasks.id]
  }

  tags = {
    Name = "${local.name}-alb"
  }
}

#checkov:skip=CKV_AWS_382:Las tareas necesitan salida a ECR y CloudWatch; las subredes públicas evitan el costo de NAT Gateway.
resource "aws_security_group" "tasks" {
  name        = "${local.name}-tasks"
  description = "Entrada a tareas solo desde el ALB"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Salida requerida para descargar imágenes y publicar logs sin NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.name}-tasks"
  }
}

resource "aws_vpc_security_group_ingress_rule" "tasks_from_alb" {
  security_group_id            = aws_security_group.tasks.id
  description                  = "Tráfico de la API solo desde el ALB"
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.app_port
  to_port                      = var.app_port
  ip_protocol                  = "tcp"
}

#checkov:skip=CKV_AWS_382:Las tareas necesitan salida HTTPS a ECR y CloudWatch; las subredes públicas evitan el costo de NAT Gateway.
resource "aws_vpc_security_group_egress_rule" "tasks_internet" {
  security_group_id = aws_security_group.tasks.id
  description       = "Salida requerida para descargar imágenes y publicar logs sin NAT"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
