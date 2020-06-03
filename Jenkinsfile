currentBuild.displayName = "#${BUILD_NUMBER}"
currentBuild.description = "Deploy testing app"

pipeline {
    agent {
        label 'provisioner'
    }
    options {
        timestamps()
    }
    parameters {
        text(
            name: "TFVARS",
            description: "Contents of the tfvars file to run terraform"
        )
        text(
            name: "TF_BACKEND",
            description: "Contents of the backend.tf file"
        )
        text(
            name: "ANSIBLE_CONF",
            description: "Contents of the ansible yaml configuration"
        )
    }
    stages {
        stage('Retrieve code') {
            steps {
                git 'https://github.com/znk3r/jenkins_test'
            }
        }
        stage('Configure terraform') {
            steps {
                sh """set +e;
echo \"${TFVARS}\" > terraform.tfvars
echo \"${TF_BACKEND}\" > backend.tf
                """
            }
        }
        stage('Terraform plan') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-access-key-id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-secret-key')
                AWS_DEFAULT_REGION = 'us-west-2'
            }
            steps {
                sh 'terraform init'
                sh 'terraform plan -out myplan'
            }
        }
        stage('Terraform approval') {
            steps {
                script {
                    def userInput = input(
                        id: 'confirm', 
                        message: 'Do you want to apply these changes?', 
                        parameters: [
                            [
                                $class: 'BooleanParameterDefinition', 
                                defaultValue: false, 
                                description: 'Apply terraform', 
                                name: 'confirm'
                            ] 
                        ]
                    )
                }
            }
        }
        stage('Terraform apply') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins-access-key-id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-secret-key')
                AWS_DEFAULT_REGION = 'us-west-2'
            }
            steps {
                sh 'terraform apply -input=false myplan'
            }
        }
        stage('Configure ansible') {
            steps {
                sh """echo \"${ANSIBLE_CONF}\" > ansible/vars.yml"""
            }
        }
        stage('Run ansible') {
            steps {
                ansiblePlaybook(
                    credentialsId: 'jenkins-test-private-key',
                    inventory: 'ansible/inventory.yml', 
                    playbook: 'ansible/playbook.yml'
                )
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
