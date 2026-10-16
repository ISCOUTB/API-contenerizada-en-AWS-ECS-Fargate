# Bootstrap de Terraform

Este módulo se aplica una sola vez y de forma manual/local con credenciales del equipo. Crea el bucket versionado y cifrado del estado, bloquea el acceso público y configura la confianza OIDC para GitHub Actions.

## Estado actual

El bootstrap ya está preparado y documentado en el repositorio. La estructura del módulo incluye:

- `main.tf` para crear el bucket y la política de bloqueo.
- `variables.tf` para definir el nombre del bucket.
- `outputs.tf` para devolver `github_actions_role_arn`.
- la documentación de uso para configurar variables de repositorio.

En este punto, la parte técnica del bootstrap está definida y lista para ejecutarse; lo que falta es su aplicación real en la cuenta de AWS del equipo para generar los valores concretos del entorno.

## Aplicación inicial

1. Verifique que su perfil local de AWS tenga permisos administrativos suficientes y que Terraform 1.10 o posterior esté instalado. No use credenciales personales en GitHub.
2. Desde esta carpeta, inicialice Terraform y proporcione un nombre globalmente único para el bucket:

```powershell
terraform init
terraform plan -var="state_bucket_name=nombre-unico-del-equipo"
terraform apply -var="state_bucket_name=nombre-unico-del-equipo"
```

La primera aplicación usa el estado local de este módulo. Guárdelo de forma segura y no lo publique; no es el estado principal de la infraestructura.

3. Copie el valor de `github_actions_role_arn` mostrado por Terraform y agréguelo como variable de repositorio `AWS_ROLE_ARN`. Configure también `AWS_REGION` con la región elegida.
4. Cree las variables de repositorio `TF_STATE_BUCKET` con el nombre del bucket y `TF_STATE_KEY` con una clave como `domusnet/ecs-fargate/terraform.tfstate`.

El rol solo confía en `ISCOUTB/API-contenerizada-en-AWS-ECS-Fargate`, para ejecuciones de las ramas `main` y `master` y eventos `pull_request`, y exige la audiencia `sts.amazonaws.com`. Los permisos quedan limitados al repositorio y al contexto necesario para desplegar.

No se crean access keys. La credencial temporal se obtiene mediante OIDC durante cada workflow. No elimine el proveedor OIDC ni el bucket mientras el repositorio aún dependa de ellos.

## Conclusión

El bootstrap ya está implementado y documentado. Su ejecución real es el siguiente paso operativo para dejar el entorno preparado y poder seguir con el despliegue completo de la infraestructura y la aplicación.

