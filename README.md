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

El objetivo aquí es eliminar por completo el uso de contraseñas o *Connection Strings* guardadas en el código o en variables de entorno. Para lograr esta seguridad "Zero Trust", el flujo de autenticación funciona así:

1. **Preparación (Terraform):** Se habilita OpenID Connect (OIDC) en el clúster AKS y se crea una Identidad Gestionada (*Managed Identity*) en Azure.
2. **El puente de confianza:** Mediante credenciales federadas, vinculamos la cuenta de servicio de Kubernetes (ServiceAccount) con la identidad de Azure para que ambos sistemas confíen el uno en el otro.
3. **Autenticación invisible:** Cuando la aplicación arranca, el clúster inyecta de forma automática y transparente un token temporal y seguro directamente en el Pod.
4. **Acceso con permisos mínimos:** El código (usando el SDK de Node.js) detecta ese token y se conecta a Azure. Gracias a que le hemos asignado una política RBAC muy restrictiva (*Storage Blob Data Reader*), la app solo tiene permiso para leer imágenes del Storage Account privado, todo sin exponer un solo secret.

---

## Infraestructura (Terraform)

La carpeta `terraform` contiene la configuración modularizada para desplegar el clúster en Microsoft Azure (AKS). Para inicializar y validar los cambios:

```bash
cd terraform
az login
terraform init
terraform plan
terraform apply
