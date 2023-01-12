#!/usr/bin/env bash

export TF_STATE_BUCKET="tf-jenkins-state-bucket3"
export TF_STATE_OBJECT_KEY="spot-jenkins.tfstate"
export TF_LOCK_DB="tf-jenkins-lock"
export AWS_REGION=ap-northeast-2

PRIVATE_SUBNETS='["subnet-0758c0b4a477fe7e1","subnet-0e69d1d8ae049cccb","subnet-0034b4bf6a038a5fe"]'

export TF_VAR_vpc_id="vpc-0bc7c4c30a5793bac"
export TF_VAR_private_subnet_ids=${PRIVATE_SUBNETS}
export TF_VAR_jenkins_agent_ami_id="ami-0a860a2421eae99d7"
export TF_VAR_jenkins_controller_ami_id="ami-0a88560cd29ff6e1c"
