# Evidencias del taller

## Estado actual del repositorio

El proyecto ya ha avanzado de forma consistente en estos puntos:

- Aplicación FastAPI preparada y con endpoints funcionales.
- Dockerfile para la API.
- Infraestructura Terraform para ECS Fargate, ALB y red.
- Bootstrap para S3 + OIDC.
- Workflows de GitHub Actions para validación, despliegue y seguridad.
- Documentación técnica completa en README y documentos de `docs/`.

Sin embargo, la evidencia final de ejecución real en AWS todavía está pendiente de completar. El repositorio contiene la base del taller, pero no hay enlaces ni capturas definitivas de despliegue ya ejecutado.

## Ejecución de workflows

- Workflow de aplicación: pendiente de ejecución real en AWS.
- Workflow de infraestructura: pendiente de ejecución real con resultados del entorno.
- Workflow de seguridad: preparado en repositorio, pero faltan resultados vinculados a una ejecución concreta.

## Resultados de Checkov

- Ejecución/enlace: pendiente.
- Hallazgos aceptados y justificación: pendientes de documentar con el resultado final de la infraestructura aplicada.

## Resultados de Trivy

- Análisis del sistema de archivos: pendiente de ejecutar en una PR o push real y adjuntar el SARIF.
- Análisis de imagen: pendiente de ejecución con la imagen publicada.
- Artefacto SARIF: pendiente de adjuntar.

## Cambio de aplicación desplegado

- Cambio realizado: pendiente de aplicación real en AWS.
- SHA de imagen: pendiente.
- Ejecución del workflow: pendiente.

## Cambio de infraestructura aplicado

- Cambio realizado: pendiente de aplicar y registrar en la ejecución real.
- Plan/aplicación: pendiente de documentar con salida del workflow y output final.

## Aplicación publicada (URL)

- URL: pendiente.
- Respuesta de `/health`: pendiente.
- Respuesta de `/info`: pendiente.

## Logs en CloudWatch

- Grupo de logs: pendiente de confirmar con el entorno desplegado.
- Captura o enlace: pendiente.

## Destrucción de la infraestructura

- Ejecución controlada: pendiente.
- Confirmación de recursos eliminados: pendiente.
- Limpieza pendiente de imágenes, versiones del estado o bucket: pendiente.

## Resumen de avance

El taller está técnicamente bien estructurado y documentado, pero su cierre exige evidencia operacional. La documentación base ya está preparada; falta completar la parte ejecutiva con resultados reales de AWS y GitHub Actions.

