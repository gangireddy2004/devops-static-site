pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "gangireddy16/devops-static-site:latest"
        EC2_IP = "13.233.224.253"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                url: 'https://github.com/gangireddy2004/devops-static-site.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t $DOCKER_IMAGE .
                '''
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    '''
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                sh '''
                docker push $DOCKER_IMAGE
                '''
            }
        }

        stage('Deploy to AWS EC2') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@$EC2_IP "
                    sudo docker pull $DOCKER_IMAGE &&
                    sudo docker stop static-site || true &&
                    sudo docker rm static-site || true &&
                    sudo docker run -d --name static-site -p 80:80 $DOCKER_IMAGE
                    "
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'AWS EC2 deployment successful!'
        }

        failure {
            echo 'Pipeline failed. Check Jenkins logs.'
        }
    }
}