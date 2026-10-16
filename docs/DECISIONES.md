# Decisiones, limitaciones y mejoras

## Decisiones del taller

- **Fargate sin servidores administrados:** ECS ejecuta contenedores sin gestionar instancias EC2. La capacidad de la tarea se fija en el mínimo solicitado: 256 CPU y 512 MiB, con una tarea deseada.
- **Subredes públicas y ausencia de NAT:** tanto ALB como tareas están en dos subredes públicas. La tarea recibe IP pública para acceder a ECR y CloudWatch; el security group impide conexiones entrantes directas. Se evita el costo recurrente de un NAT Gateway.
- **HTTP en el ALB:** no se configura HTTPS porque el taller no suministra dominio ni certificado ACM. La API no debe manejar datos sensibles. En `alb.tf` se justifica el hallazgo Checkov `CKV_AWS_2`; para un despliegue real, asociar un dominio y certificado TLS y redirigir HTTP a HTTPS.
- **Acceso público del ALB y egreso:** el ingreso HTTP público (`CKV_AWS_260`) es necesario para probar el endpoint sin dominio y se exceptúa en `security.tf`; el egreso de las tareas está acotado por puerto (443 para ECR/CloudWatch y 53 para DNS), por lo que `CKV_AWS_382` no aplica y no requiere excepción.
- **Política de ejecución de ECS:** `CKV_AWS_356` se exceptúa solo para `ecr:GetAuthorizationToken`, una operación que AWS requiere con recurso `*`; la descarga de capas está limitada al ARN del repositorio del proyecto.
- **Logs de acceso y borrado del ALB:** `CKV_AWS_91` se acepta para no añadir un bucket dedicado a logs y `CKV_AWS_150` para permitir la destrucción manual del entorno de laboratorio. Los logs de la aplicación permanecen en CloudWatch.
- **ECR mutable:** `latest` es necesario para la definición de tarea inicial y el flujo de introducción. El workflow también etiqueta cada imagen con el SHA y solo publica luego de pasar Trivy. En `ecr.tf` se documenta el hallazgo `CKV_AWS_51`. Para producción, preferir etiquetas inmutables y retirar la dependencia de `latest`.
- **Egreso acotado de las tareas:** sin NAT ni endpoints privados, las tareas requieren salida para descargar capas de ECR y publicar logs. Se permite egreso solo a 443 (HTTPS) y 53 (DNS UDP/TCP). En un entorno sensible, evaluar VPC endpoints de ECR, S3 y CloudWatch Logs y limitar destinos.
- **Sin logs de acceso del ALB:** no se crea otro bucket para los logs del balanceador para no sumar recursos/costo al ejercicio. Los logs de aplicación sí se envían a CloudWatch.
- **Borrado de recursos de laboratorio:** el ALB no tiene protección contra eliminación y el repositorio ECR permite borrado con imágenes para facilitar el `destroy` controlado. El bucket del bootstrap sí tiene `prevent_destroy`.
- **Sin permisos de aplicación:** el task role no tiene políticas porque esta API no llama a otros servicios AWS. El execution role tiene únicamente permisos para descargar del repositorio ECR y escribir en el grupo de logs.
- **Estado remoto y OIDC:** el estado usa S3 cifrado/versionado con bloqueo nativo `use_lockfile`; el rol de Actions confía solo en el repositorio del equipo, las ramas `main` y `master` y el sujeto `pull_request`. Las credenciales son temporales.
- **Retención corta de logs:** los grupos de CloudWatch usan `var.log_retention_days` (7 días por defecto) para controlar costos; se exceptúa `CKV_AWS_338` en `logs.tf` porque no se almacenan datos sensibles ni de auditoría.

## Limitaciones conocidas

- El ALB tiene un costo por hora y por unidades LCU aunque no haya tráfico; detener o destruir el servicio es importante al terminar el taller.
- Las tareas tienen IP pública y salida a Internet. El acceso entrante a la aplicación sigue restringido al ALB, pero la arquitectura no es una red privada de producción.
- El primer despliegue de infraestructura registra una task definition con `latest` antes de que la imagen esté publicada. El scheduler ECS vuelve a intentar iniciar tareas cuando no puede descargarla; ejecutar el workflow de aplicación publica `latest` y fuerza un nuevo despliegue con el SHA. Si el circuito de despliegue marca fallida la primera revisión antes de publicar la imagen, ejecutar de nuevo el workflow de aplicación después del bootstrap.
- Los permisos de EC2, ELB y ECS del rol de Actions incluyen acciones de administración/discovery con recursos `*` donde AWS no ofrece un alcance práctico antes de conocer los ARN. IAM se acota a los roles del proyecto (`ecs-*` y `flow-logs`), ECR al prefijo del repositorio, los log groups a `/ecs/*` y `/vpc/*`, y el estado al bucket creado. KMS y el proveedor OIDC usan `*` porque sus ARN no se conocen antes de crearlos. Para cuentas compartidas, revisar políticas con IAM Access Analyzer.
- `force_delete` en ECR puede eliminar imágenes al destruir el repositorio. El workflow de destrucción no elimina el bucket de estado ni su historial versionado.

## Mejoras posibles

1. Añadir ACM, DNS y listener HTTPS con redirección desde HTTP.
2. Mover tareas a subredes privadas e incorporar VPC endpoints para ECR, S3 y CloudWatch Logs, evaluando su costo frente a NAT.
3. Habilitar logs de acceso de ALB, alarmas CloudWatch, métricas y alertas de disponibilidad.
4. Usar escaneo continuo, firma/verificación de imágenes, etiquetas ECR inmutables y promoción de imágenes entre entornos.
5. Restringir el rol OIDC por ambiente protegido y condiciones adicionales de GitHub; auditar permisos con IAM Access Analyzer.
