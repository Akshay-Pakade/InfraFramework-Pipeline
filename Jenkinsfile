pipeline {
    agent any

    environment {
        ARM_CLIENT_ID       = credentials('arm-client-id')
        ARM_CLIENT_SECRET   = credentials('arm-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('arm-sub-id')
        ARM_TENANT_ID       = credentials('arm-tenant-id')
        TF_ROOT             = 'JioCloudInfra'
        TF_PLAN             = 'tfplan'
    }

    options {
        timestamps()
        skipStagesAfterUnstable()
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/Akshay-Pakade/InfraFramework-Pipeline.git'
            }
        }

        stage('Check Workspace') {
            steps {
                sh 'pwd'
                sh 'ls -R'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_ROOT}") {
                    sh 'terraform init -backend-config=backend.tf'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_ROOT}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_ROOT}") {
                    sh "terraform plan -out=${TF_PLAN}"
                }
            }
        }

        stage('Manual Approval') {
            steps {
                input message: 'Approve Infrastructure Deployment?'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_ROOT}") {
                    sh "terraform apply -auto-approve ${TF_PLAN}"
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning workspace...'
            cleanWs()
        }
        success {
            echo 'Terraform executed successfully ✅'
        }
        failure {
            echo 'Terraform failed ❌'
        }
    }
}
