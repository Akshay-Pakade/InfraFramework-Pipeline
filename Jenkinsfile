pipeline {
    agent any

    environment {
        ARM_CLIENT_ID       = credentials('arm-client-id')
        ARM_CLIENT_SECRET   = credentials('arm-client-secret')
        ARM_SUBSCRIPTION_ID = credentials('arm-sub-id')
        ARM_TENANT_ID       = credentials('arm-tenant-id')
    }

    options {
        timestamps()
    }

    stages {

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('JioCloudInfra') {
                sh 'terraform plan -out=tfplan'
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
                sh 'terraform apply tfplan'
            }
        }
    }
}
