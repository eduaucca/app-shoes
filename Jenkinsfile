pipeline {
    agent {
        node {
            label 'built-in'
        }
    } 

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

       stage('Análisis de Código (SonarQube)') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'

                    withSonarQubeEnv('sonar-server') {
                        withCredentials([string(credentialsId: 'sonar-token-nuevo', variable: 'SONAR_TOKEN')]) {
                            sh """${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=app-shoes \
                                -Dsonar.projectName='App Shoes' \
                                -Dsonar.sources=. \
                                -Dsonar.exclusions=**/node_modules/**"""
                        }
                    }
                }
            }
        } 
        
        stage('Autenticación en Azure y ACR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'azure-sp', passwordVariable: 'AZ_PASS', usernameVariable: 'AZ_USER')]) {
                    // Login en Azure con el Service Principal
                    sh "az login --service-principal -u \$AZ_USER -p \$AZ_PASS --tenant 3f83c7e1-a93e-45f3-83e5-1848086ae31f"
                    // Login específico en el Container Registry para que Docker pueda hacer push
                    sh "az acr login --name ${ACR_NAME}"
                }
            }
        }

        stage('Construir Imagen Docker') {
            steps {
                // Gracias al sidecar de DinD, esto se compila localmente dentro del pod de Jenkins
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
                    withCredentials([usernamePassword(credentialsId: 'azure-sp', passwordVariable: 'AZ_PASS', usernameVariable: 'AZ_USER')]) {
                        sh "az login --service-principal -u \$AZ_USER -p \$AZ_PASS --tenant 3f83c7e1-a93e-45f3-83e5-1848086ae31f"
                        sh "az aks get-credentials --resource-group rg-shoes-dev --name aks-shoes-cluster"
                        
                        // Aquí es donde va la nueva línea que inyecta las credenciales a Helm:
                        sh "helm upgrade --install app-shoes . --set image.repository=${IMAGE_NAME} --set image.tag=${IMAGE_TAG} --set azure.clientId=\$AZ_USER --set azure.clientSecret=\$AZ_PASS --set azure.tenantId=3f83c7e1-a93e-45f3-83e5-1848086ae31f"
                    }
                }
            }
         }
      }
   }

