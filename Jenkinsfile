pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:${env.PATH}"
    }

    stages {
        stage('Test Shell') {
            steps {
                sh 'echo "Testing Shell"'
                sh 'which terraform'
                sh 'terraform --version'
            }
        }
    }
}
