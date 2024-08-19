pipeline {
    agent any

    environment {
        PATH = "/usr/local/bin:/opt/homebrew/bin:$PATH"
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_REGION = 'us-east-1'
        ECR_URI = ""
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
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('infra') {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Display Terraform Plan') {
            steps {
                dir('infra') {
                    sh 'terraform show -no-color tfplan'
                }
            }
        }

        stage('Manual Approval - Apply') {
            when {
                expression { return params.ACTION == 'apply' }
            }
            steps {
                input message: 'Approve the Terraform Plan for apply?', ok: 'Apply'
            }
        }

        stage('Terraform Apply and Save Output') {
            when {
                expression { return params.ACTION == 'apply' }
            }
            steps {
                dir('infra') {
                    script {
                        // Apply the Terraform plan
                        def applyOutput = sh(returnStdout: true, script: 'terraform apply -auto-approve tfplan').trim()
                        echo "Terraform Apply Output: ${applyOutput}"  // Debugging line

                        // Capture Terraform outputs to a JSON file
                        def output = sh(returnStdout: true, script: 'terraform output -json').trim()
                        echo "Terraform JSON Output: ${output}"  // Debugging line
                        
                        // Write the JSON output to a file
                        writeFile file: 'terraform_output.json', text: output
                        echo "Output written to terraform_output.json"  // Debugging line
                    }
                }
            }
        }

        stage('Manual Approval - Destroy') {
            when {
                expression { return params.ACTION == 'destroy' }
            }
            steps {
                input message: 'Approve the Terraform Plan for destroy?', ok: 'Destroy'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { return params.ACTION == 'destroy' }
            }
            steps {
                dir('infra') {
                    sh 'terraform destroy -auto-approve'
                }
            }
        }

        stage('Parse Terraform Output') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    // Check if the JSON file exists
                    if (fileExists('infra/terraform_output.json')) {
                        echo "terraform_output.json contents:"
                        sh "cat infra/terraform_output.json"
                        
                        // Attempt to read the file
                        def output = readJSON file: 'infra/terraform_output.json'
                        ECR_URI = output.ecr_repository_url.value
                        echo "Parsed ECR URI: ${ECR_URI}"
                    } else {
                        error "terraform_output.json not found!"
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
                    echo "Building Docker image with ECR URI: ${ECR_URI}"  // Debugging line
                    sh "docker build -t my-flask-app ."
                }
            }
        }

        stage('Login to ECR') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "Logging in to ECR: ${ECR_URI}"  // Debugging line
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URI}"
                }
            }
        }

        stage('Tag and Push Docker Image') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                script {
                    echo "Tagging and pushing Docker image to: ${ECR_URI}"  // Debugging line
                    sh "docker tag my-flask-app:latest ${ECR_URI}:latest"
                    sh "docker push ${ECR_URI}:latest"
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
