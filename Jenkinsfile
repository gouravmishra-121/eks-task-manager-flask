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

        stage('Approval and Apply/Destroy') {
            when {
                anyOf {
                    expression { params.ACTION == 'apply' }
                    expression { params.ACTION == 'destroy' }
                }
            }
            steps {
                script {
                    if (params.ACTION == 'apply') {
                        input message: 'Approve the Terraform Plan?', ok: 'Apply'
                        dir('infra') {
                            sh 'terraform apply -auto-approve tfplan'
                        }
                    } else if (params.ACTION == 'destroy') {
                        input message: 'Approve the destruction of Terraform infrastructure?', ok: 'Destroy'
                        dir('infra') {
                            sh 'terraform destroy -auto-approve'
                        }
                    }
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
            // Add additional failure notifications or actions here if needed
        }
    }
}
