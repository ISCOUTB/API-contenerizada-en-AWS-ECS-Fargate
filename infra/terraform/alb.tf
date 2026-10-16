
#trivy:ignore:AVD-AWS-0053:ALB publico por diseno para la demo sin dominio; el ingreso a tareas sigue restringido al ALB.
resource "aws_lb" "api" {
  name                       = substr("${local.name}-alb", 0, 32)
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = aws_subnet.public[*].id
  enable_deletion_protection = false
  drop_invalid_header_fields = true

  #checkov:skip=CKV_AWS_91:El taller de bajo costo no crea un bucket adicional para los logs de acceso.
  #checkov:skip=CKV_AWS_150:Se permite destruir los recursos del laboratorio mediante el workflow manual.
  #checkov:skip=CKV2_AWS_28:El taller educativo no incluye AWS WAF para evitar recursos adicionales.
  #checkov:skip=CKV2_AWS_20:No hay dominio ni certificado TLS configurado para redirigir HTTP a HTTPS.

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

  #checkov:skip=CKV_AWS_378:El taller utiliza HTTP entre el ALB y la API; no hay TLS configurado en la aplicación.

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

#trivy:ignore:AVD-AWS-0054:Sin certificado TLS disponible para el taller; la API no maneja datos sensibles.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  #checkov:skip=CKV_AWS_2:No hay certificado TLS disponible para el taller.
  #checkov:skip=CKV_AWS_103:No se puede configurar TLS 1.2 sin habilitar HTTPS y disponer de un certificado.
  #checkov:skip=CKV2_AWS_20:No hay listener HTTPS al cual redirigir las solicitudes HTTP.

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}
