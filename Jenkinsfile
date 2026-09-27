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
    }
}
