pipeline {
    agent {
        kubernetes {
            inheritFrom 'canary-demo'
            defaultContainer 'p1'
            yaml """
apiVersion: v1
kind: Pod
spec:
  imagePullSecrets:
    - name: regcred
  containers:
  - name: jnlp
    image: quay.io/flysangel/inbound-agent:4.13-2-jdk11
  - name: p1
    securityContext:
      privileged: true
    image: quay.io/podman/stable:v3.4.7
    command: ["sleep"]
    args: ["infinity"]
  - name: k1
    securityContext:
      privileged: true
    image: quay.io/grassknot/kubectl:1.24.1
    command: ["sleep"]
    args: ["infinity"]
"""
        }
    }
    environment {
        QUAY_ADMIN = credentials('quay-admin-id')
        KUBECONFIG = credentials('kubeconfig-id')
        IMAGE_TAG = "quay.io/robinwu456/alpine.httpd:${env.BRANCH_NAME}.${env.BUILD_NUMBER}"
    }
    stages {
        stage ('build and push image') {
            steps {
                sh 'podman login --tls-verify=false -u=${QUAY_ADMIN_USR} -p=${QUAY_ADMIN_PSW} quay.io'
                sh 'podman build --tls-verify=false -t "${IMAGE_TAG}" .'
                sh 'podman images'
                sh 'podman push --tls-verify=false "${IMAGE_TAG}"'
            }
        }
        stage ('deploy canary') {
            when { branch 'canary' }
            steps {
                container('k1') {
                    sh 'mkdir -p ~/.kube && cp ${KUBECONFIG} ~/.kube/config'
                    sh "sed -i.bak 's#quay.io/robinwu456/alpine.httpd:1.0.0#${IMAGE_TAG}#' b1-canary.yaml"
                    sh 'kubectl apply -f service.yaml -n prod'
                    sh 'kubectl apply -f b1-canary.yaml -n prod'
                }
            }
        }
        stage ('deploy prod') {
            when { branch 'master' }
            steps {
                container('k1') {
                    sh 'mkdir -p ~/.kube && cp ${KUBECONFIG} ~/.kube/config'
                    sh "sed -i.bak 's#quay.io/robinwu456/alpine.httpd:1.0.0#${IMAGE_TAG}#' b1-prod.yaml"
                    sh 'kubectl apply -f service.yaml -n prod'
                    sh 'kubectl apply -f b1-prod.yaml -n prod'
                }
            }
        }
        stage ('deploy dev') {
            when {
                not { branch 'master' }
                not { branch 'canary' }
            }
            steps {
                container('k1') {
                    sh 'kubectl get ns ${BRANCH_NAME} || kubectl create ns ${BRANCH_NAME}'
                    sh 'mkdir -p ~/.kube && cp ${KUBECONFIG} ~/.kube/config'
                    sh "sed -i.bak 's#quay.io/robinwu456/alpine.httpd:1.0.0#${IMAGE_TAG}#' b1-dev.yaml"
                    sh "sed -i.bak 's#LoadBalancer#ClusterIP#' service.yaml"
                    sh 'kubectl apply -f service.yaml -n ${BRANCH_NAME}'
                    sh 'kubectl apply -f b1-dev.yaml -n ${BRANCH_NAME}'
                }
            }
        }
    }
}
