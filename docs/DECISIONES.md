# Decisiones, limitaciones y mejoras

## Estado de avance del proyecto

El repositorio muestra un avance técnico sólido y homogéneo con el enfoque del taller. Ya ha quedado preparado:

- código de la aplicación,
- contenedor Docker,
- infraestructura Terraform,
- bootstrap para el backend remoto,
- OIDC para GitHub Actions,
- workflows de validación y despliegue,
- documentación de arquitectura y decisiones.

La parte que todavía queda como cierre operativo es la validación real en AWS y la documentación de evidencias ejecutadas con capturas y resultados concretos.

## Decisiones del taller

- Fargate sin servidores administrados: ECS ejecuta contenedores sin gestionar instancias EC2. La capacidad de la tarea se fija en el mínimo solicitado: 256 CPU y 512 MiB, con una tarea deseada de 1.
- Subredes públicas y ausencia de NAT: tanto ALB como tareas están en dos subredes públicas. La tarea recibe IP pública para acceder a ECR y CloudWatch; el security group impide conexiones entrantes no autorizadas.
- HTTP en el ALB: no se configura HTTPS porque el taller no suministra dominio ni certificado ACM. La API no debe manejar datos sensibles.
- Acceso público del ALB y egreso: el ingreso HTTP público se mantiene por necesidad de pruebas del endpoint sin dominio.
- Política de ejecución de ECS: se aplica el mínimo necesario para que la tarea pueda descargar la imagen y registrar logs.
- Logs de acceso y borrado del ALB: se aceptan decisiones de simplicidad para no crear recursos adicionales.
- ECR mutable: `latest` es necesario para la definición de tarea inicial y el flujo de introducción. El workflow también etiqueta cada imagen con el SHA y solo publica luego de pasar Trivy.
- Egreso acotado de las tareas: sin NAT ni endpoints privados, las tareas requieren salida para descargar capas de ECR y publicar logs. Se permite egreso solo a 443 (HTTPS) y 53 (DNS UDP/TCP).
- Estado remoto y OIDC: el estado usa S3 cifrado/versionado con bloqueo nativo; el rol de Actions confía solo en el repositorio y ramas autorizadas.
- Retención corta de logs: los grupos de CloudWatch usan retención limitada para controlar costos.

## Limitaciones conocidas

- El ALB tiene un costo por hora y por unidades LCU aunque no haya tráfico; detener o destruir el servicio es importante al terminar el taller.
- Las tareas tienen IP pública y salida a Internet. El acceso entrante a la aplicación sigue restringido al ALB, pero la arquitectura no es una red privada de producción.
- El primer despliegue de infraestructura registra una task definition con `latest` antes de que la imagen esté publicada; ECS reintenta iniciar tareas cuando no puede descargar la imagen.
- Los permisos del rol de Actions incluyen acciones administrativas donde AWS no ofrece un alcance práctico antes de conocer los ARN.
- `force_delete` en ECR puede eliminar imágenes al destruir el repositorio. El workflow de destrucción no elimina el bucket de estado ni su historial versionado.

## Mejoras posibles

1. Añadir ACM, DNS y listener HTTPS con redirección desde HTTP.
2. Mover tareas a subredes privadas e incorporar VPC endpoints para ECR, S3 y CloudWatch Logs, evaluando su costo frente a NAT.
3. Habilitar logs de acceso de ALB, alarmas CloudWatch, métricas y alertas de disponibilidad.
4. Usar escaneo continuo, firma/verificación de imágenes, etiquetas ECR inmutables y promoción de imágenes entre entornos.
5. Restringir el rol OIDC por ambiente protegido y condiciones adicionales de GitHub; auditar permisos con IAM Access Analyzer.

## Conclusión del estado actual

El proyecto ha superado la fase de estructura inicial y ya dispone de una solución técnicamente coherente y documentada. Lo que resta es la entrega definitiva: ejecutar los workflows en AWS, confirmar que la API responde correctamente, y dejar la evidencia en `docs/EVIDENCIAS.md` para que el taller quede cerrado y trazable.

