pipeline {
    agent any
    
    environment {
        DISCORD_WEBHOOK_URL = credentials('discord-webhook')
        IMAGE_NAME = 'jenkins-discord-app'
        NAMESPACE = 'jenkins-app'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '📥 Checking out code from GitHub...'
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Docker image...'
                script {
                    sh "docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} ."
                    sh "docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${IMAGE_NAME}:latest"
                }
            }
        }
        
        stage('Create Kubernetes Namespace') {
            steps {
                echo '📦 Creating Kubernetes namespace...'
                sh 'kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -'
            }
        }
        
        stage('Update Kubernetes Secret') {
            steps {
                echo '🔐 Updating Discord webhook secret...'
                sh '''
                    kubectl create secret generic discord-webhook \
                    --from-literal=DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL}" \
                    --namespace=${NAMESPACE} \
                    --dry-run=client -o yaml | kubectl apply -f -
                '''
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                echo '🚀 Deploying to Kubernetes...'
                script {
                    // Replace BUILD_NUMBER in deployment.yaml
                    sh """
                        sed 's/BUILD_NUMBER/${BUILD_NUMBER}/g' deployment.yaml > deployment-${BUILD_NUMBER}.yaml
                        kubectl apply -f deployment-${BUILD_NUMBER}.yaml
                    """
                }
            }
        }
        
        stage('Wait for Deployment') {
            steps {
                echo '⏳ Waiting for deployment to complete...'
                sh 'kubectl rollout status deployment/jenkins-discord-app -n ${NAMESPACE} --timeout=2m'
            }
        }
        
        stage('Verify Deployment') {
            steps {
                echo '✅ Verifying deployment...'
                sh 'kubectl get pods -n ${NAMESPACE}'
                sh 'kubectl get services -n ${NAMESPACE}'
            }
        }
        
        stage('View Application Logs') {
            steps {
                echo '📋 Viewing application logs...'
                script {
                    sh '''
                        sleep 5
                        POD_NAME=$(kubectl get pods -n ${NAMESPACE} -l app=jenkins-discord-app -o jsonpath='{.items[0].metadata.name}')
                        kubectl logs $POD_NAME -n ${NAMESPACE} || echo "Pod not ready yet"
                    '''
                }
            }
        }
    }
    
    post {
        success {
            echo '🎉 Pipeline completed successfully!'
            echo '✅ Application deployed to Kubernetes'
            echo '💬 Discord notification sent'
        }
        failure {
            echo '❌ Pipeline failed!'
            echo '🔍 Check the logs above for details'
        }
        always {
            echo '🧹 Cleaning up temporary files...'
            sh "rm -f deployment-${BUILD_NUMBER}.yaml || true"
        }
    }
}
