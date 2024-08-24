pipeline {
    agent any

    environment {
        PATH = "/usr/local/bin:/opt/homebrew/bin:$PATH"
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY = '905418002997.dkr.ecr.us-east-1.amazonaws.com/my-flask-app'
    }

    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose apply to deploy or destroy to delete')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('flaskapp') {
                    echo "Building Docker image with ECR URI"
                    sh "docker build --platform linux/amd64 -t my-flask-app ."
                }
            }
        }

        stage('Login to ECR') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "Logging in to ECR"
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPOSITORY}"
                }
            }
        }

        stage('Tag and Push Docker Image') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "Tagging and pushing Docker image"
                    sh "docker tag my-flask-app:latest ${ECR_REPOSITORY}:latest"
                    sh "docker push ${ECR_REPOSITORY}:latest"
                }
            }
        }

        stage('Configure EKS') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "Configuring kubectl to use EKS cluster"
                    sh "aws eks update-kubeconfig --name my-cluster --region ${AWS_REGION}"
                }
            }
        }

        stage('Apply Kubernetes Manifests') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('manifest') {
                    echo "Applying Kubernetes manifests"
                    sh "kubectl apply -f deployment.yml"
                    sleep time: 60, unit: 'SECONDS'
                    sh "kubectl apply -f service.yml"
                    sleep time: 60, unit: 'SECONDS'
                    sh "kubectl apply -f cloudwatch-agent-configmap.yml"
                    sleep time: 60, unit: 'SECONDS'
                    sh"kubectl apply -f cloudwatch-agent-daemonset.yaml"
                }
            }
        }

        stage('Destroy Kubernetes Manifests') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                dir('manifest') {
                    echo "Destroying Kubernetes manifests"
                    sh "kubectl delete -f deployment.yml"
                    sh "kubectl delete -f service.yml"
                }
            }
        }
        stage('Check Kubernetes Resources') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "Checking Kubernetes resources"
                    sh "kubectl get pods"
                    sh "kubectl get services"
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
