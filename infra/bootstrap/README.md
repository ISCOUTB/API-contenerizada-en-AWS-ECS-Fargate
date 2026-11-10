
# Bootstrap de Terraform - DOMUSNET

## 1. Introducción

El módulo bootstrap prepara los recursos iniciales que necesita Terraform para administrar la infraestructura de DOMUSNET.

Su ejecución se realiza una sola vez desde una máquina autorizada y con credenciales de AWS del equipo.

Este módulo crea:

- Un bucket S3 para almacenar el estado remoto de Terraform.
- Versionado del bucket.
- Cifrado del almacenamiento mediante SSE-S3 (AES256).
- Bloqueo del acceso público.
- Una política que rechaza conexiones inseguras sin HTTPS.
- Un proveedor de identidad OIDC para GitHub Actions.
- Un rol IAM para que GitHub Actions pueda acceder a AWS.

## 2. Requisitos previos

Antes de ejecutar el bootstrap se necesita:

- Terraform 1.10 o posterior.
- AWS CLI instalado.
- Credenciales válidas de una cuenta AWS autorizada.
- Permisos suficientes para crear recursos S3 e IAM.
- Acceso al repositorio de GitHub del proyecto.

El repositorio asociado al módulo es:

https://github.com/ISCOUTB/API-contenerizada-en-AWS-ECS-Fargate

La región predeterminada del bootstrap es `us-east-1` (N. Virginia). Debe mantenerse igual que la región acordada por el equipo para el despliegue principal.

## 3. Verificar la cuenta de AWS

Antes de ejecutar Terraform, se debe comprobar que las credenciales corresponden a la cuenta autorizada del equipo.

Desde macOS o Linux:

```bash
aws sts get-caller-identity
```

Si se utiliza un perfil específico:

```bash
export AWS_PROFILE="perfil-autorizado-del-equipo"

aws sts get-caller-identity
```

No se debe continuar si la identidad o la cuenta devuelta no corresponden al entorno autorizado.

No se deben incluir credenciales permanentes de AWS en el repositorio.

## 4. Ubicación del módulo

Desde la raíz del repositorio, el módulo se encuentra en:

`infra/bootstrap/`

Los archivos principales son:

| Archivo | Función |
|---|---|
| main.tf | Define el bucket S3, OIDC, rol y permisos IAM. |
| variables.tf | Define la región, nombre del bucket y parámetros del proyecto. |
| outputs.tf | Devuelve los identificadores de los recursos creados. |
| README.md | Explica el procedimiento de configuración. |

## 5. Preparar el bootstrap

Abrir una Terminal y ubicarse en la raíz del repositorio.

Inicializar Terraform:

```bash
terraform -chdir=infra/bootstrap init
```

Comprobar el formato:

```bash
terraform -chdir=infra/bootstrap fmt -check
```

Validar la configuración:

```bash
terraform -chdir=infra/bootstrap validate
```

## 6. Crear el bucket de estado y configurar OIDC

Se debe proporcionar un nombre globalmente único para el bucket S3.

El nombre utilizado en este ejemplo es únicamente ilustrativo y debe reemplazarse por uno elegido por el equipo:

```bash
terraform -chdir=infra/bootstrap plan \
  -var="state_bucket_name=domusnet-terraform-state-equipo-12345" \
  -var="aws_region=us-east-1"
```

Después de revisar el plan y confirmar que los recursos y la cuenta son correctos, se ejecuta:

```bash
terraform -chdir=infra/bootstrap apply \
  -var="state_bucket_name=domusnet-terraform-state-equipo-12345" \
  -var="aws_region=us-east-1"
```

Terraform solicitará confirmación antes de crear los recursos.

El mismo nombre del bucket y la misma región deben utilizarse en las ejecuciones posteriores.

## 7. Estado local del bootstrap

La primera ejecución del bootstrap utiliza un estado local de Terraform.

El archivo `terraform.tfstate` generado en esta carpeta contiene información de los recursos creados y debe mantenerse protegido.

No debe:

- Subirse al repositorio.
- Compartirse públicamente.
- Eliminarse sin un procedimiento de recuperación.
- Confundirse con el estado remoto de la infraestructura principal.

El archivo está contemplado en las reglas de exclusión de Git.

El bucket S3 que crea el bootstrap se utiliza posteriormente como backend remoto del proyecto principal.

## 8. Consultar los outputs

Después de aplicar correctamente el bootstrap se pueden consultar sus outputs.

Nombre del bucket:

```bash
terraform -chdir=infra/bootstrap output -raw state_bucket_name
```

ARN del rol de GitHub Actions:

```bash
terraform -chdir=infra/bootstrap output -raw github_actions_role_arn
```

ARN del proveedor OIDC:

```bash
terraform -chdir=infra/bootstrap output -raw github_oidc_provider_arn
```

Estos valores deben conservarse para configurar la integración entre GitHub y AWS.

## 9. Configuración de variables en GitHub

Desde el repositorio se debe ingresar a:

`Settings → Secrets and variables → Actions → Variables`

Las variables requeridas son:

| Variable | Valor |
|---|---|
| AWS_REGION | Región AWS acordada por el equipo. |
| AWS_ROLE_ARN | Output github_actions_role_arn. |
| TF_STATE_BUCKET | Output state_bucket_name. |
| TF_STATE_KEY | domusnet/ecs-fargate/terraform.tfstate. |

La clave del estado debe ser acordada y mantenerse igual en todos los despliegues.

## 10. Entorno protegido

El workflow de Terraform utiliza el entorno de GitHub:

`aws-infrastructure`

Este entorno debe crearse desde:

`Settings → Environments`

Se recomienda configurar un revisor obligatorio y restringir los despliegues a las ramas principales autorizadas.

La política de confianza del rol IAM debe coincidir con el sujeto OIDC que genera GitHub al utilizar este entorno.

Para los trabajos asociados al entorno, el sujeto tiene el formato:

`repo:ISCOUTB/API-contenerizada-en-AWS-ECS-Fargate:environment:aws-infrastructure`

El bootstrap debe ajustarse para permitir este contexto y evitar que los Pull Requests puedan asumir el rol de despliegue.

La actualización y aplicación de la política IAM debe realizarse de manera coordinada con el responsable de la cuenta AWS.

## 11. Consideraciones de seguridad

- El bucket S3 mantiene el versionado habilitado.
- Se utiliza cifrado SSE-S3 mediante AES256.
- El acceso público está bloqueado.
- Se rechaza el transporte inseguro.
- La autenticación de GitHub Actions utiliza OIDC.
- No se necesitan access keys permanentes dentro de GitHub.
- Los permisos IAM deben limitarse al repositorio y a las operaciones requeridas.

El rol de despliegue contiene permisos de administración sobre varios recursos AWS. Su alcance debe revisarse periódicamente para mantener el principio de mínimo privilegio.

## 12. Estado de implementación

El código Terraform del bootstrap está preparado para crear los recursos iniciales.

Su disponibilidad real depende de que el responsable de AWS ejecute el procedimiento con las credenciales autorizadas y compruebe los outputs generados.

La configuración OIDC debe quedar coordinada con el workflow actualizado antes de habilitar los despliegues automáticos.

## 13. Conclusión

El bootstrap permite preparar los recursos básicos para que Terraform mantenga su estado remoto y GitHub Actions pueda autenticarse en AWS.

Su ejecución constituye el primer paso operativo para habilitar la automatización de infraestructura de DOMUSNET.
