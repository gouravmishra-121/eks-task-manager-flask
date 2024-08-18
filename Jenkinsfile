pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:${env.PATH}"
    }

    stages {
        stage('Debug') {
            steps {
                sh 'echo $PATH'
                sh 'which sh'
                sh 'sh --version'
            }
        }

        stage('Test Shell') {
            steps {
                sh 'echo "Testing Shell"'
                sh 'which terraform'
                sh 'terraform --version'
            }
        }
    }
}
