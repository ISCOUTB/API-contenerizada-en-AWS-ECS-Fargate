
# Decisiones, limitaciones y mejoras

## Estado de avance del proyecto

El repositorio contiene los componentes principales para implementar DOMUSNET mediante AWS y Terraform. Entre ellos se encuentran:

- Código de la aplicación.
- Contenedor Docker.
- Infraestructura definida con Terraform.
- Bootstrap para preparar el backend remoto.
- Configuración de identidad OIDC para GitHub Actions.
- Workflows de validación, despliegue y seguridad.
- Documentación de arquitectura y decisiones técnicas.

La parte que todavía queda como cierre operativo es la validación real en AWS y la documentación de las evidencias obtenidas durante las ejecuciones, incluyendo capturas y resultados concretos.

## Decisiones del taller

- **Fargate sin servidores administrados:** ECS ejecuta contenedores sin necesidad de gestionar instancias EC2. La capacidad de la tarea se fija en 256 unidades de CPU y 512 MiB de memoria, con una tarea deseada de 1.

- **Subredes públicas y ausencia de NAT:** tanto el ALB como las tareas se encuentran en dos subredes públicas. Las tareas reciben IP pública para acceder a ECR y CloudWatch; el Security Group impide conexiones entrantes no autorizadas.

- **HTTP en el ALB:** no se configura HTTPS porque el taller no suministra un dominio ni un certificado ACM. La API no debe manejar datos sensibles.

- **Acceso público del ALB:** se mantiene el ingreso HTTP público para permitir las pruebas del endpoint sin necesidad de configurar un dominio.

- **Política de ejecución de ECS:** se aplican los permisos necesarios para que las tareas puedan descargar imágenes y registrar logs.

- **Logs de acceso y borrado del ALB:** se mantienen decisiones de simplicidad para evitar crear recursos adicionales.

- **ECR mutable:** se utiliza la etiqueta `latest` para la definición de tarea inicial y el flujo de introducción. El workflow también etiqueta cada imagen con el SHA del commit y publica únicamente después de pasar el análisis de Trivy.

- **Egreso acotado de las tareas:** al no utilizar NAT ni endpoints privados, las tareas requieren salida para descargar capas de ECR y publicar logs. Se permite egreso por los puertos 443 (HTTPS) y 53 (DNS UDP/TCP).

- **Estado remoto de Terraform:** el backend utiliza Amazon S3 con cifrado habilitado (`encrypt = true`) y bloqueo de estado mediante `use_lockfile = true`. El bootstrap contempla versionado y bloqueo del acceso público al bucket.

- **Autenticación OIDC:** el bootstrap configura un proveedor de identidad para GitHub Actions. La política de confianza todavía requiere ajustes para retirar el acceso desde `pull_request` y permitir el contexto del entorno protegido `aws-infrastructure` para Terraform. Se debe conservar el acceso por ramas autorizado que necesita el workflow de publicación de la aplicación.

- **Retención corta de logs:** los grupos de CloudWatch utilizan una retención limitada para controlar costos.

- **Actualización del sistema base:** el Dockerfile incluye `apt-get upgrade` para mitigar vulnerabilidades del sistema operativo base Debian slim.

- **Excepciones en Trivy de contenedor:** se excluyen en `.trivyignore` vulnerabilidades transitorias de Starlette, utilizada por FastAPI 0.115.

## Limitaciones conocidas

- El ALB tiene un costo por hora y por unidades LCU, incluso cuando no hay tráfico. Por eso, detener o destruir el servicio es importante al terminar el taller.

- Las tareas tienen IP pública y salida a Internet. El acceso entrante a la aplicación sigue restringido al ALB, pero esta arquitectura no utiliza una red privada propia de producción.

- En el primer despliegue de infraestructura se registra una task definition con la etiqueta `latest` antes de que la imagen esté publicada. ECS puede reintentar iniciar las tareas cuando todavía no logra descargar la imagen.

- Los permisos del rol de GitHub Actions incluyen algunas acciones administrativas cuyo alcance debe revisarse y limitarse según los ARN de los recursos creados.

- La opción `force_delete` de ECR puede eliminar imágenes cuando se destruye el repositorio. El workflow de destrucción no elimina el bucket del bootstrap ni su historial versionado.

## Mejoras posibles

1. Añadir ACM, DNS y un listener HTTPS con redirección desde HTTP.

2. Mover las tareas a subredes privadas e incorporar VPC Endpoints para ECR, S3 y CloudWatch Logs, evaluando su costo frente a NAT Gateway.

3. Habilitar logs de acceso del ALB, alarmas de CloudWatch, métricas y alertas de disponibilidad.

4. Incorporar escaneo continuo, firma y verificación de imágenes, etiquetas ECR inmutables y promoción de imágenes entre entornos.

5. Restringir el rol OIDC mediante entornos protegidos y condiciones adicionales de GitHub. Complementar la revisión de permisos con IAM Access Analyzer.

## Conclusión del estado actual

El proyecto cuenta con una estructura técnica definida mediante Terraform, una aplicación contenerizada y workflows preparados para automatizar diferentes etapas del proceso.

Sin embargo, tener el código y las automatizaciones configuradas no significa que todos los recursos estén funcionando en AWS. Para cerrar el proyecto es necesario ejecutar los workflows con la cuenta autorizada del equipo, verificar que la API responda correctamente y registrar los resultados reales en `docs/EVIDENCIAS.md`.

