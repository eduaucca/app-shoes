# App Shoes - DevOps & Zero Trust Cloud Architecture

Proyecto personal de infraestructura y despliegue continuo centrado en seguridad, automatización y buenas prácticas en la nube. 

El objetivo principal de este proyecto es desplegar una aplicación web en un clúster de Kubernetes en Azure (AKS) conectándose a un Blob Storage privado sin utilizar ninguna credencial estática ni contraseñas, aplicando una arquitectura Zero Trust real mediante identidades federadas.

---

## Stack Tecnológico

- **Aplicación:** Node.js (Express)
- **Contenedores:** Docker
- **Orquestación:** Kubernetes y Helm Charts
- **CI/CD:** Jenkins y GitHub
- **Infra Cloud:** Terraform para provisionar clústeres AKS, Azure Container Registry (ACR) y Blob Storage privado en Azure
- **Observabilidad:** Prometheus (prom-client)

---

## Cómo está estructurado

- `terraform/`: Código de infraestructura para levantar la red, el grupo de recursos, el clúster AKS (con OIDC habilitado), ACR y el Storage Account privado.
- `helm/`: Plantillas parametrizadas para desplegar la aplicación en Kubernetes separando entornos y configurando las anotaciones necesarias para la inyección de identidad.
- `src/`: Aplicación en Node.js que utiliza el SDK oficial de Azure (`DefaultAzureCredential`) para autenticarse en el clúster de forma nativa.
- `Jenkinsfile`: Pipeline de despliegue automatizado para construir la imagen de Docker, subirla a ACR y desplegar la nueva versión en AKS usando Helm.

---

## Arquitectura de Seguridad (Zero Trust)

En lugar de guardar una Connection String o claves de acceso en el código o en variables de entorno inseguras, el flujo funciona así:
1. Terraform crea una Managed Identity en Azure y configura el clúster AKS con OpenID Connect (OIDC).
2. Mediante una Federated Identity Credential, se vincula la ServiceAccount de Kubernetes con la identidad de Azure.
3. Al arrancar la aplicación, el clúster inyecta de forma transparente un token temporal en el Pod.
4. El SDK de Node.js detecta ese token automáticamente y se conecta de forma segura gracias a la política RBAC (Storage Blob Data Reader), leyendo las imágenes del Storage Account privado sin exponer ningún secreto.

---

## Infraestructura (Terraform)

La carpeta `terraform` contiene la configuración modularizada para desplegar el clúster en Microsoft Azure (AKS). Para inicializar y validar los cambios:

```bash
cd terraform
az login
terraform init
terraform plan
terraform apply
