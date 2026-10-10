# App Shoes - Node.js Application & Kubernetes Deployment

A personal project focused on software development, containerization, and continuous deployment in Kubernetes following a Zero Trust architecture.

This repository contains exclusively the source code of the web application, its Docker containerization, Helm charts, and the automation pipeline. The core infrastructure provisioning on Azure is managed independently in the [app-shoes-infra](https://github.com/tu-usuario/app-shoes-infra) repository.

## Tech Stack

- **Application:** Node.js (Express)
- **Containers:** Docker and Kaniko
- **Orchestration:** Kubernetes and Helm Charts
- **CI/CD:** Jenkins (`Jenkinsfile`)
- **Cloud Security:** Azure Workload Identity integration using `DefaultAzureCredential`

## Repository Structure

- `src/`: Source code of the application, configured to authenticate natively with Azure services (such as the private Blob Storage).
- `helm/`: Parameterized Helm chart templates for clean and scalable deployments on the AKS cluster.
- `Dockerfile`: Definition for building the application container image.
- `Jenkinsfile`: Automated CI/CD pipeline that builds the code, generates the container image, pushes it to the Azure Container Registry (ACR), and updates the deployment on AKS using Helm.

## Zero Trust Security Architecture

The application interacts with cloud services without using static credentials or connection strings in the code:
1. **Transparent Authentication:** Uses the official Azure SDK (`DefaultAzureCredential`), automatically detecting the temporary token injected by the AKS cluster via federated identities.
2. **Least Privilege Principle:** Through Azure roles assigned in the infrastructure, the application has only the strictly necessary permissions over the storage container.

## Continuous Deployment

The automated pipeline in Jenkins executes the following phases:
1. Repository checkout.
2. Docker image build.
3. Secure authentication to the Azure Container Registry (ACR).
4. Publishing the new image version.
5. Executing Helm commands to update the Kubernetes cluster in the target environment.
