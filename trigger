pipeline {
    agent any
    
    environment {
        INSTANCE_IP = '107.21.87.127' // Update with your instance2 IP address
        REPO_DIR = '/var/www/html/drupal' // Directory where the repository is cloned on the instance
        GIT_BRANCH = 'main' // Branch to pull
        GIT_REMOTE_URL = 'https://github.com/Sindhu-M29/drupalnew.git' // URL of the Git repository
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[credentialsId: 'Git-token', url: GIT_REMOTE_URL]]
                ])
            }
        }
        
        stage('Deploy') {
            steps {
                script {
                    // Use credentials for SSH authentication
                    withCredentials([usernamePassword(credentialsId: '66ecbb51-faa1-44e5-858b-bf2efd064f2c', usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        // SSH into the instance and execute commands
                        sh '''
                        echo "Connecting to $USER@$INSTANCE_IP and pulling the latest changes"

                        sshpass -p $PASS ssh -o StrictHostKeyChecking=no $USER@$INSTANCE_IP "
                            cd $REPO_DIR
                            git remote add origin $GIT_REMOTE_URL
                            git fetch origin
                            git pull origin $GIT_BRANCH
                        "
                        '''
                    }
                }
            }
        }
    }
}
