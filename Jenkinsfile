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
                echo "Jenkins Workspace Path:"
                sh 'pwd'
                echo "Workspace Folder Structure:"
                sh 'ls -R'
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_ROOT}") {
                    echo "Initializing Terraform in ${TF_ROOT}..."
                    sh 'terraform init'   // <- backend.tf remove kar diya
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_ROOT}") {
                    echo "Validating Terraform configuration..."
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_ROOT}") {
                    echo "Generating Terraform plan..."
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
                    echo "Applying Terraform plan..."
                    sh "terraform apply -auto-approve ${TF_PLAN}"
                }
            }
        }
    }

    post {
        always {
            echo 'Cleaning Jenkins workspace...'
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
