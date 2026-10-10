# App Shoes - Node.js Application & Kubernetes Deployment

Proyecto enfocado en el desarrollo de software, contenerización y despliegue continuo en Kubernetes bajo una arquitectura Zero Trust.

Este repositorio contiene exclusivamente el código fuente de la aplicación web, su empaquetado con Docker, las plantillas de Helm y el pipeline de automatización. El aprovisionamiento de la infraestructura base en Azure se gestiona de forma independiente en el repositorio [app-shoes-infra](https://github.com/tu-usuario/app-shoes-infra).

## Stack Tecnológico

- **Aplicación:** Node.js (Express)
- **Contenedores:** Docker y Kaniko
- **Orquestación:** Kubernetes y Helm Charts
- **CI/CD:** Jenkins (`Jenkinsfile`)
- **Seguridad Cloud:** Integración con Azure Workload Identity mediante `DefaultAzureCredential`

## Estructura del Repositorio

- `src/`: Código fuente de la aplicación, configurado para autenticarse de forma nativa con los servicios de Azure (como el Blob Storage privado).
- `helm/`: Plantillas parametrizadas de Helm Charts para realizar despliegues limpios y escalables en el clúster AKS.
- `Dockerfile`: Definición para la construcción de la imagen de la aplicación.
- `Jenkinsfile`: Pipeline automatizado de CI/CD que compila el código, genera la imagen de contenedor, la publica en el Azure Container Registry (ACR) y actualiza el despliegue en AKS utilizando Helm.

## Arquitectura de Seguridad (Zero Trust)

La aplicación interactúa con los servicios en la nube sin utilizar credenciales estáticas ni cadenas de conexión en el código:
1. **Autenticación transparente:** Utiliza el SDK oficial de Azure (`DefaultAzureCredential`), detectando de forma automática el token temporal inyectado por el clúster AKS a través de identidades federadas.
2. **Principio de mínimo privilegio:** Mediante roles de Azure asignados en la infraestructura, la aplicación cuenta únicamente con los permisos estrictamente necesarios sobre el contenedor de almacenamiento.

## Despliegue Continuo

El pipeline automatizado en Jenkins ejecuta las siguientes fases:
1. Clonación del repositorio.
2. Construcción de la imagen de Docker.
3. Autenticación segura en el Azure Container Registry (ACR).
4. Publicación de la nueva versión de la imagen.
5. Ejecución de los comandos de Helm para actualizar el clúster de Kubernetes en el entorno de destino.
