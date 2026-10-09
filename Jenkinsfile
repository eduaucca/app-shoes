pipeline {
    agent {
        kubernetes {
            yamlFile 'kaniko-pod.yaml'
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

       stage('Construir y Subir con Kaniko') {
           steps {
               container('kaniko') {
                   // Líneas de diagnóstico nuevas
                   sh 'ls -la /kaniko/.docker/ || echo "Error: La carpeta no existe"'
                   sh 'ls -la /kaniko/.docker/config.json || echo "Error: El archivo config.json NO está"'
                   sh '''
                   /kaniko/executor \
                     --context $(pwd) \
                     --dockerfile $(pwd)/Dockerfile \
                     --destination acrshoesedu2026.azurecr.io/app-shoes:${BUILD_NUMBER} \
                     --destination acrshoesedu2026.azurecr.io/app-shoes:latest
                   '''
        }
    }
}
       
       stage('Actualizar Infraestructura (Terraform)') {
            steps {
                container('terraform') {
                   dir('repo-infra') {

                     git branch: 'main', url: 'https://github.com/eduaucca/app-shoes-infra.git'

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
    }        
}

        stage('Desplegar en AKS (Helm)') {
            steps {
            
                  dir('helm') {
                    withCredentials([usernamePassword(credentialsId: 'azure-sp', passwordVariable: 'AZ_PASS', usernameVariable: 'AZ_USER')]) {
                        
                        container('azure-cli') {
                        // Logea en Azure
                        sh 'az login --service-principal -u \$AZ_USER -p \$AZ_PASS --tenant 3f83c7e1-a93e-45f3-83e5-1848086ae31f'

                        // Obtiene las cedenciales del cluster AKS
                        sh 'az aks get-credentials --resource-group rg-shoes-dev --name aks-shoes-cluster --file kubeconfig_aks'
                        }
                        container('helm') {
                            sh 'export KUBECONFIG=kubeconfig_aks && helm upgrade --install app-shoes . --set image.repository=${IMAGE_NAME} --set image.tag=${IMAGE_TAG} --set azure.clientId=$AZ_USER --set azure.clientSecret=$AZ_PASS --set azure.tenantId=3f83c7e1-a93e-45f3-83e5-1848086ae31f'
                        }
                        
                   }
                }
            }
         }
      }
   }

