credentials:
  system:
    domainCredentials:
    - credentials:
      - basicSSHUserPrivateKey:
          id: "59411e8e-742e-4e83-b7c3-f0327e8d285e"
          privateKeySource:
            directEntry:
              privateKey: "{${jenkins_agent_private}}"
          scope: SYSTEM
          username: "ec2-user"
jenkins:
  agentProtocols:
  - "JNLP4-connect"
  - "Ping"
  authorizationStrategy:
    loggedInUsersCanDoAnything:
      allowAnonymousRead: false
  clouds:
  - eC2Fleet:
      addNodeOnlyIfRunning: false
      alwaysReconnect: false
      cloudStatusIntervalSec: 10
      computerConnector:
        sSHConnector:
          credentialsId: "59411e8e-742e-4e83-b7c3-f0327e8d285e"
          launchTimeoutSeconds: 60
          maxNumRetries: 10
          port: 22
          retryWaitTime: 15
          sshHostKeyVerificationStrategy: "nonVerifyingKeyVerificationStrategy"
      disableTaskResubmit: false
      fleet: ${spot-request-id}
      idleMinutes: 5
      initOnlineCheckIntervalSec: 15
      initOnlineTimeoutSec: 180
      labelString: "spot-agent"
      maxSize: 3
      maxTotalUses: -1
      minSize: 1
      minSpareSize: 0
      name: "SpotFleet"
      noDelayProvision: false
      numExecutors: 1
      privateIpUsed: true
      region: "ap-northeast-2"
      restrictUsage: false
      scaleExecutorsByWeight: false
  crumbIssuer:
    standard:
      excludeClientIPFromCrumb: false
  numExecutors: 0
  remotingSecurity:
    enabled: true
  securityRealm:
    local:
      allowsSignup: false
      users:
      - id: "lgbss"
        password: ${jenkins-pwd}
        properties:
        - "apiToken"
        - timezone:
            timeZoneName: "Asia/Tokyo"
  slaveAgentPort: 50000
globalCredentialsConfiguration:
  configuration:
    providerFilter: "none"
    typeFilter: "none"
security:
  sSHD:
    port: -1
unclassified:
  buildDiscarders:
    configuredBuildDiscarders:
    - "jobBuildDiscarder"
  buildStepOperation:
    enabled: false
  buildTimestamp:
    enableBuildTimestamp: true
    pattern: "yyyy-MM-ddHHmmss"
    timezone: "Etc/GMT-9"
tool:
  git:
    installations:
    - home: "git"
      name: "Default"
  mavenGlobalConfig:
    globalSettingsProvider: "standard"
    settingsProvider: "standard"
  sonarRunnerInstallation:
    installations:
    - name: "SonarQubeScanner-4.7.0"
      properties:
      - installSource:
          installers:
          - sonarRunnerInstaller:
              id: "4.7.0.2747"
jobs:
  - script: >
      pipelineJob('Docker Image Build Parent Pipeline') {
        definition {
          cps {
            script('''
              pipeline {
                // using the fleet instances that has the label 'spot-agent'
                agent {
                  label 'spot-agent'
                }
                stages {
                    stage('Clone source') {
                      steps {
                        sh "echo 'Updating image tag in helm chart to new \$${BUILD_TIMESTAMP}"
                      }
                    }

                    stage('Triggering child pipeline') {
                        steps {
                            sh "echo 'Triggering child pipeline and pass the value > \$${BUILD_TIMESTAMP}'"
                            build(job: 'childPipeline', parameters: [string(name: 'DOCKERTAG', value: env.\$${BUILD_TIMESTAMP})])
                        }
                    }
                }
              }'''.stripIndent())
              sandbox()
          }
        }
      }
  - script: >
      pipelineJob('Helm Chart Image Tag Update Child Pipeline') {
        definition {
          cps {
            script('''
              pipeline {
                  // using the fleet instances that has the label 'spot-agent'
                  agent {
                    label 'spot-agent'
                  }
                  
                  parameters {
                    string(name: 'DOCKERTAG', description: 'from parent jenkins job')
                  }
                  stages {
                      stage('See the value') {
                        steps {
                          sh 'echo child pipeline is triggered and passed variable is \$${params.DOCKERTAG}'
                        }
                      }  
                  }
              }'''.stripIndent())
              sandbox()
          }
        }
      }
