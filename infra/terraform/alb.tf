#checkov:skip=CKV_AWS_91:No se crea un bucket adicional para los logs de acceso en este taller de bajo costo.
#checkov:skip=CKV_AWS_150:Se permite destruir explícitamente los recursos de laboratorio desde el workflow manual.
resource "aws_lb" "api" {
  name                       = substr("${local.name}-alb", 0, 32)
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = aws_subnet.public[*].id
  enable_deletion_protection = false

  tags = {
    Name = "${local.name}-alb"
  }
}

resource "aws_lb_target_group" "api" {
  name        = substr("${local.name}-tg", 0, 32)
  port        = var.app_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${local.name}-api"
  }
}

#checkov:skip=CKV_AWS_2:El taller no dispone de dominio ni certificado TLS; no usar HTTP para datos sensibles ni producción.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
