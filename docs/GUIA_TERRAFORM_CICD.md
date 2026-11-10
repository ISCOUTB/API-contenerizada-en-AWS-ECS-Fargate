
# Guía de Terraform y GitHub Actions - DOMUSNET

## 1. Introducción

Esta guía describe cómo se administra y despliega la infraestructura de DOMUSNET mediante Terraform y GitHub Actions.

El objetivo es automatizar las verificaciones del código, el análisis de seguridad y la aplicación de cambios en AWS, reduciendo la necesidad de ejecutar manualmente todos los comandos.

## 2. Herramientas utilizadas

| Herramienta | Función |
|---|---|
| Terraform | Definir y administrar infraestructura como código. |
| AWS | Proporcionar los servicios de infraestructura. |
| Amazon S3 | Almacenar el estado remoto de Terraform. |
| GitHub | Gestionar el repositorio y los cambios. |
| GitHub Actions | Ejecutar los procesos automatizados. |
| OIDC | Permitir la autenticación entre GitHub y AWS mediante credenciales temporales. |
| Checkov | Analizar configuraciones de infraestructura y detectar problemas de seguridad. |

## 3. Estructura de los archivos

El workflow de infraestructura se encuentra en:

`.github/workflows/infra-deploy.yml`

La infraestructura principal se encuentra en:

`infra/terraform/`

La configuración inicial del backend y la identidad OIDC se encuentra en:

`infra/bootstrap/`

## 4. Funcionamiento de infra-deploy.yml

El workflow se divide en tres trabajos independientes:

### 4.1. validate: validación de Terraform

Este trabajo comprueba la configuración antes de continuar con el despliegue.

Sus pasos son:

1. Descargar el código del repositorio.
2. Configurar la versión de Terraform.
3. Ejecutar `terraform fmt -check`.
4. Inicializar los proveedores sin utilizar el backend remoto.
5. Ejecutar `terraform validate`.
6. Analizar la infraestructura con Checkov.

Este trabajo no utiliza credenciales de AWS.

Se ejecuta como requisito previo para los trabajos de despliegue.

### 4.2. deploy: despliegue de infraestructura

Este trabajo administra la infraestructura principal en AWS.

Se activa cuando se integran cambios en las ramas principales configuradas o cuando se solicita una ejecución manual autorizada.

Sus pasos son:

1. Descargar el código.
2. Configurar Terraform.
3. Comprobar las variables requeridas.
4. Obtener credenciales temporales mediante OIDC.
5. Comprobar la identidad AWS mediante `aws sts get-caller-identity`.
6. Inicializar Terraform utilizando el backend remoto S3.
7. Generar el plan con `terraform plan`.
8. Aplicar el plan generado con `terraform apply`.
9. Publicar los outputs de infraestructura.

El trabajo utiliza el entorno protegido `aws-infrastructure`, que puede requerir aprobación antes de iniciar el despliegue.

### 4.3. destroy: destrucción manual

Este trabajo está destinado a eliminar la infraestructura principal cuando sea necesario.

Para ejecutarlo se requiere:

- Iniciar manualmente el workflow.
- Seleccionar la opción `destroy`.
- Ejecutarlo desde una rama principal autorizada.
- Escribir exactamente `DESTROY DOMUSNET`.
- Obtener la aprobación del entorno protegido.

Esta operación debe realizarse únicamente con autorización del equipo.

El bucket utilizado por el bootstrap debe conservarse mientras se necesite el estado remoto de Terraform.

## 5. Configuración de GitHub

Las variables necesarias se configuran desde:

`Settings → Secrets and variables → Actions → Variables`

Se utilizan las siguientes variables:

| Variable | Descripción |
|---|---|
| AWS_REGION | Región de AWS utilizada por el proyecto. |
| AWS_ROLE_ARN | ARN del rol IAM que utilizará GitHub Actions. |
| TF_STATE_BUCKET | Nombre del bucket S3 que almacena el estado. |
| TF_STATE_KEY | Ruta del archivo de estado dentro del bucket. |

Los valores del rol y del bucket se obtienen después de ejecutar correctamente el bootstrap.

No se deben almacenar credenciales permanentes de AWS en el repositorio.

## 6. Entorno protegido de despliegue

El workflow utiliza un entorno de GitHub llamado:

`aws-infrastructure`

Este entorno permite establecer revisores obligatorios y limitar las ramas autorizadas para desplegar.

Los trabajos `deploy` y `destroy` deben utilizar este entorno.

La política de confianza OIDC configurada en AWS debe permitir el sujeto correspondiente al repositorio y al entorno protegido.

## 7. Ejecución local de Terraform

Desde la raíz del repositorio se pueden ejecutar las siguientes comprobaciones:

### Verificar formato

```bash
terraform fmt -check -recursive infra/terraform
```

### Inicializar sin backend remoto

```bash
terraform -chdir=infra/terraform init -backend=false -input=false
```

### Validar la configuración

```bash
terraform -chdir=infra/terraform validate
```

Estas comprobaciones permiten detectar errores de formato y configuración sin modificar la infraestructura desplegada.

## 8. Flujo de trabajo del equipo

El procedimiento habitual para modificar la infraestructura es:

1. Crear una rama de trabajo.
2. Modificar los archivos Terraform.
3. Guardar los cambios.
4. Ejecutar las validaciones locales.
5. Crear un commit.
6. Subir la rama a GitHub.
7. Abrir un Pull Request.
8. Revisar los resultados de las comprobaciones.
9. Aprobar e integrar el Pull Request.
10. Aprobar la ejecución del entorno protegido.
11. Comprobar el resultado del despliegue y sus outputs.

## 9. Seguridad

Se consideran las siguientes medidas:

- Uso de OIDC para obtener credenciales temporales.
- Permisos mínimos para cada trabajo.
- Validaciones de Terraform antes del despliegue.
- Análisis de seguridad con Checkov.
- Protección del entorno de despliegue.
- Exclusión de archivos de estado y credenciales del repositorio.
- Conservación del lockfile de Terraform para fijar versiones de proveedores.

## 10. Solución de problemas comunes

| Problema | Posible solución |
|---|---|
| Terraform no está instalado | Instalar Terraform y comprobar `terraform version`. |
| Error en el formato | Ejecutar `terraform fmt -recursive infra/terraform`. |
| Error en validate | Revisar los archivos `.tf`. |
| Falta una variable de GitHub | Comprobar las variables del repositorio. |
| Error de autenticación OIDC | Revisar proveedor, rol IAM y política de confianza. |
| Error con el backend S3 | Comprobar bucket, región, clave y permisos. |
| Error durante Checkov | Revisar los controles de seguridad incumplidos. |
| Despliegue pendiente de aprobación | Consultar el entorno `aws-infrastructure` en GitHub. |

## 11. Verificación final

La validación local de Terraform no demuestra que los recursos estén funcionando en AWS.

Para confirmar el despliegue es necesario revisar las ejecuciones de GitHub Actions y comprobar los recursos en la cuenta AWS del equipo.

Los resultados reales deben registrarse en:

`docs/EVIDENCIAS.md`

## 12. Conclusión

Terraform y GitHub Actions permiten automatizar la administración de la infraestructura de DOMUSNET.

La combinación de validaciones, análisis de seguridad, revisión de cambios y aprobación de despliegues proporciona un proceso más ordenado, controlado y reproducible.
