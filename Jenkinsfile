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
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'uat'],
            description: 'Choose environment'
        )
        text(
            name: "ENV_NAME",
            description: "Unique name for the environment you want to create. It'll be used to create unique resources and could be used as part of DNS entries."
        )
        text(
            name: "PARAMETER_STORE_NAMESPACE",
            description: "Base SSM parameter store namespace where configurations are stored."
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
aws ssm get-parameter --name \"${PARAMETER_STORE_NAMESPACE}/${ENVIRONMENT}.tfvars\" --output json | jq .Parameter.Value -r > ${ENVIRONMENT}.tfvars
                """
                sh """set +e;
aws ssm get-parameter --name \"${PARAMETER_STORE_NAMESPACE}/${ENVIRONMENT}/${ENV_NAME}.tfvars\" --output json | jq .Parameter.Value -r > project.tfvars
                """
                sh """set +e;
aws ssm get-parameter --name \"${PARAMETER_STORE_NAMESPACE}/${ENVIRONMENT}.backend.tf\" --output json | jq .Parameter.Value -r > backend.tf
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
                sh 'terraform init -no-color'
                sh """terraform plan -no-color -var-file=\"${ENVIRONMENT}.tfvars\" -var-file=\"project.tfvars\" -out myplan"""
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
                                defaultValue: true, 
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
                sh 'terraform apply -no-color -input=false myplan'
            }
        }
        stage('Configure ansible') {
            steps {
                sh """set +e;
aws ssm get-parameter --name \"${PARAMETER_STORE_NAMESPACE}/${ENVIRONMENT}/${ENV_NAME}.ansible.yml\" --output json | jq .Parameter.Value -r > ansible/vars.yml
                """
            }
        }
        stage('Run ansible') {
            environment {
                ANSIBLE_HOST_KEY_CHECKING = false
            }
            steps {
                ansiblePlaybook(
                    credentialsId: 'jenkins-test-private-key',
                    inventory: 'ansible/inventory.yml', 
                    playbook: 'ansible/playbook.yml',
                    hostKeyChecking: false,
                    colorized: true
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
