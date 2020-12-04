@Library('slack-notifier-lib')
void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/NetApp/ez-rancher"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

pipeline {
    triggers {
        cron(env.BRANCH_NAME == 'main' ? '0 */4 * * *' : '')
    }
    agent {
      kubernetes {
        label 'ez-rancher'
        defaultContainer 'jnlp'
        yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins
    component: builder
spec:
  serviceAccountName: jenkins
  containers:
    - name: tf
      image: hashicorp/terraform:0.14.0
      tty: true
      command: ["cat"]
    - name: dind
      image: docker:dind
      args:
      - --dns-opt='options single-request'
      securityContext:
        privileged: true
      volumeMounts:
        - name: dind-storage
          mountPath: /var/lib/docker
  volumes:
    - name: dind-storage
      emptyDir: {}
"""
      }
    }
    environment {
        COMMIT_SLUG = "${GIT_COMMIT}".substring(0,8)
    }
    stages {
        stage ('Prepare') {
            steps {
                container('jnlp') {
                script {
                    def myRepo = checkout scm
                    def gitCommit = "${GIT_COMMIT}"
                    def gitBranch = "${GIT_BRANCH}"
                    def previousGitCommit = sh(script: "git rev-parse ${gitCommit}~", returnStdout: true)
                }
            } }
        }

        stage ('Validate') {
            steps {
                setBuildStatus("Build succeeded", "PENDING");
                container('tf') {
                    sh """
                        apk add --no-cache curl
                        terraform fmt -check -recursive -diff .
                        """
                }
                container('tf') {
                    sh """
                        cd terraform/vsphere-rancher
                        terraform init
                        """
                }
                container('tf') {
                    sh """
                        terraform validate
                        """
                }
            }
        }

        stage ('Build') {
            steps {
                container('dind') {
                    sh """
                        docker build --network host --no-cache -t ez-rancher:${COMMIT_SLUG} .
                        """
                }
            }
        }


        stage ('Deploy') {
            steps {
                container('dind') {
                    withCredentials([file(credentialsId: 'ez-rancher-olab', variable: 'TFVARS')]) {
                    sh """
                        cd terraform/vsphere-rancher
                        apk add --no-cache bash make
                        cat ${TFVARS} > env.list
                        echo "TF_VAR_vm_name=ezr-${COMMIT_SLUG}" >> env.list
                        mkdir deliverables  
                        EZR_IMAGE_NAME=ez-rancher
                        EZR_IMAGE_TAG=latest
                        DELIVERABLES=deliverables
                        docker run --rm --env-file env.list \
                            -v `pwd`/deliverables:/terraform/vsphere-rancher/deliverables \
                            --network host \
                            ez-rancher:${COMMIT_SLUG} apply -auto-approve -input=false
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            container('dind') {
                sh """
                    cd terraform/vsphere-rancher
                    docker run --rm --env-file env.list \
                        -v `pwd`/deliverables:/terraform/vsphere-rancher/deliverables \
                        --network host \
                        ez-rancher:${COMMIT_SLUG} destroy -auto-approve -input=false
                    """
            }
            container('dind') {
                sh """
                    docker rmi ez-rancher:${COMMIT_SLUG}
                    """
            }
            notifySlack currentBuild.result
        }
        success {
            setBuildStatus("Build succeeded", "SUCCESS");
        }
        failure {
            setBuildStatus("Build failed", "FAILURE");
        }
    } 
}