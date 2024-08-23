pipeline {
    agent any

    environment {
        PATH = "/usr/local/bin:/opt/homebrew/bin:$PATH"
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_REGION = 'us-east-1'
        KUBECONFIG = "${HOME}/.kube/config"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        

        stage('Build Docker Image') {
            steps {
                dir('flaskapp') {
                    echo "Building Docker image with ECR URI"
                    sh "docker build --platform linux/amd64 -t my-flask-app ."
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    echo "Logging in to ECR"
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin 905418002997.dkr.ecr.us-east-1.amazonaws.com/my-flask-app"
                }
            }
        }

        stage('Tag and Push Docker Image') {
            steps {
                script {
                    echo "Tagging and pushing Docker image to"
                    sh "docker tag my-flask-app:latest 905418002997.dkr.ecr.us-east-1.amazonaws.com/my-flask-app:latest"
                    sh "docker push 905418002997.dkr.ecr.us-east-1.amazonaws.com/my-flask-app:latest"
                }
            }
        }

    }  

    post {
        always {
            cleanWs()
        }
    }
}
