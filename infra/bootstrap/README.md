# Bootstrap de Terraform

Este módulo se aplica **una sola vez y de forma manual/local** con credenciales del equipo. Crea el bucket versionado y cifrado del estado, bloquea el acceso público y configura la confianza OIDC y el rol de GitHub Actions. El bucket tiene `prevent_destroy`; su eliminación requiere una acción explícita y planificada.

## Aplicación inicial

1. Verifique que su perfil local de AWS tenga permisos administrativos suficientes y que Terraform 1.10 o posterior esté instalado. No use credenciales personales en GitHub.
2. Desde esta carpeta, inicialice Terraform y proporcione un nombre globalmente único para el bucket:

   ```powershell
   terraform init
   terraform plan -var="state_bucket_name=nombre-unico-del-equipo"
   terraform apply -var="state_bucket_name=nombre-unico-del-equipo"
   ```

   La primera aplicación usa el estado local de este módulo. Guárdelo de forma segura y no lo publique; no es el estado principal de la infraestructura.
3. Copie el valor de `github_actions_role_arn` mostrado por Terraform y agréguelo como **variable de repositorio** `AWS_ROLE_ARN`. Configure también `AWS_REGION` con la región elegida.
4. Cree las variables de repositorio `TF_STATE_BUCKET` con el nombre del bucket y `TF_STATE_KEY` con una clave como `domusnet/ecs-fargate/terraform.tfstate`. El backend usa el bloqueo nativo S3 (`use_lockfile`), sin tabla DynamoDB.

El rol solo confía en `ISCOUTB/API-contenerizada-en-AWS-ECS-Fargate`, para ejecuciones de las ramas `main` y `master` y eventos `pull_request`, y exige la audiencia `sts.amazonaws.com`. Los permisos son deliberadamente funcionales para esta infraestructura; IAM está limitado a los roles ECS del proyecto, ECR al prefijo del repositorio y el estado al bucket creado. Las API de ECS, EC2 y ELB requieren permisos de descubrimiento/gestión más amplios por sus relaciones entre recursos. Revise el archivo `main.tf` antes de aplicar en una cuenta compartida.

No se crean access keys. La credencial temporal se obtiene mediante OIDC durante cada workflow. No elimine el proveedor OIDC ni el bucket mientras el repositorio aún dependa de ellos.
