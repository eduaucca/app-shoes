pipeline {
    agent any 

    environment {
        // Variables para tu Azure Container Registry
        ACR_NAME = "acrshoesedu2026" 
        IMAGE_NAME = "${ACR_NAME}.azurecr.io/app-shoes"
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Autenticación en Azure y ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-sp', passwordVariable: 'AZ_PASS', usernameVariable: 'AZ_USER')]) {
                    // Login en Azure con el Service Principal
                    sh "az login --service-principal -u \$AZ_USER -p \$AZ_PASS --tenant 3f83c7e1-a93e-45f3-83e5-1848086ae31f"
                    // Login específico en el Container Registry
                    sh "az acr login --name ${ACR_NAME}"
                }
            }
        }
        
        stage('Construir Imagen Docker') {
            steps {
                // Ejecutado en la raíz donde está el Dockerfile
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
            }
        }
        
        stage('Subir a Azure Container Registry') {
            steps {
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${IMAGE_NAME}:latest"
            }
        }
        
       stage('Actualizar Infraestructura (Terraform)') {
            steps {
                dir('terraform') {
                    withCredentials([usernamePassword(credentialsId: 'azure-sp', passwordVariable: 'ARM_CLIENT_SECRET', usernameVariable: 'ARM_CLIENT_ID')]) {
                        withEnv([
                            "ARM_TENANT_ID=3f83c7e1-a93e-45f3-83e5-1848086ae31f", 
                            "ARM_SUBSCRIPTION_ID=1a4b81c6-bca5-4df9-8ec9-19efa91fa5f0"
                        ]) {
                            sh 'terraform init'
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }
        
        stage('Desplegar en AKS (Helm)') {
            steps {
                dir('helm') {
                    sh "helm upgrade --install app-shoes ./mi-chart --set image.repository=${IMAGE_NAME} --set image.tag=${IMAGE_TAG}"
                }
            }
        }
    }
}
