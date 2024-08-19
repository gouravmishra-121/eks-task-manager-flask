pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:$PATH"
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_REGION = 'us-east-1' // Set your AWS region
    }
    
    parameters {
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'Choose whether to apply or destroy Terraform infrastructure.')
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                dir('infra') {
                    script {
                        sh 'terraform init'
                    }
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    script {
                        sh 'terraform plan -out=tfplan'
                    }
                }
            }
        }

        stage('Display Terraform Plan') {
            steps {
                dir('infra') {
                    script {
                        sh 'terraform show -no-color tfplan'
                    }
                }
            }
        }

        stage('Manual Approval') {
            when {
                expression { return params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                script {
                    input message: "Approve the Terraform ${params.ACTION}?", ok: "${params.ACTION.capitalize()}"
                }
            }
        }

        stage('Execute Terraform Action') {
            when {
                expression { return params.ACTION == 'apply' || params.ACTION == 'destroy' }
            }
            steps {
                dir('infra') {
                    script {
                        if (params.ACTION == 'apply') {
                            sh 'terraform apply -auto-approve tfplan'
                            sh 'terraform output -json > terraform_output.json'
                        } else if (params.ACTION == 'destroy') {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
                }
            }
        }

        stage('Parse Terraform Output') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    // Read and print the output file for debugging
                    sh 'cat infra/terraform_output.json'
                    
                    def outputJson = readJSON file: 'infra/terraform_output.json'
                    
                    if (outputJson['ecr_repository_url']) {
                        def ecrUri = outputJson['ecr_repository_url']
                        env.ECR_URI = ecrUri
                        echo "ECR URI: ${env.ECR_URI}"
                    } else {
                        error "ECR URI not found in Terraform output"
                    }
                }
            }
        }

        stage('Build Docker Image') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                dir('flaskapp') {
                    script {
                        sh 'docker build -t my-flask-app:latest .'
                    }
                }
            }
        }

        stage('Login to ECR') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${env.ECR_URI}
                    """
                }
            }
        }

        stage('Tag Docker Image') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    sh """
                    docker tag my-flask-app:latest ${env.ECR_URI}/my-flask-app:latest
                    """
                }
            }
        }

        stage('Push Docker Image to ECR') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    sh """
                    docker push ${env.ECR_URI}/my-flask-app:latest
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Clean up the workspace
        }
        success {
            echo 'Pipeline completed successfully'
        }
        failure {
            echo 'Pipeline failed'
        }
    }
}
