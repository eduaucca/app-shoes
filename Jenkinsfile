pipeline {
    agent any 

    environment {
        // Variables para Azure Container Registry (ACR)
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
        
        stage('Construir Imagen Docker') {
            steps {
                 
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} -t ${IMAGE_NAME}:latest ."
                
            }
        }
        
        stage('Subir a Azure Container Registry') {
            steps {
                // Para que Jenkins use las credenciales configuradas para subir la imagen
                sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
                sh "docker push ${IMAGE_NAME}:latest"
            }
        }
        
        stage('Actualizar Infraestructura (Terraform)') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
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

        stage('Autenticación en Azure y ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-sp', passwordVariable: 'AZ_PASS', usernameVariable: 'AZ_USER')]) {
                    // Login en Azure con el Service Principal
                    sh "az login --service-principal -u \$AZ_USER -p \$AZ_PASS --tenant TU_TENANT_ID"
                    // Login específico en el Container Registry
                    sh "az acr login --name ${ACR_NAME}"
                }
            }
        
        }
}
