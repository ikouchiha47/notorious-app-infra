#!/bin/bash
#
# Wrapper over terraform commands and helpers
#
#
BACKEND_CONFIG="${BACK_CFG:-./infra.hcl}"
DOMAIN_NAME="${DOMAIN_NAME:-}"
VPC_NAME="${VPC_NAME:-}"
CLUSTER_NAME="${CLUSTER_NAME:-}"



function plan() {
  echo "domain $DOMAIN_NAME"
  echo "cluster $CLUSTER_NAME"

  echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform -chdir=./services init -backend-config="${BACKEND_CONFIG}"

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    TF_VAR_DOMAIN_NAME=${DOMAIN_NAME} \
    TF_VAR_VPC_NAME=${VPC_NAME} \
    TF_VAR_ECS_CLUSTER_NAME=${CLUSTER_NAME} \
    terraform -chdir=./services validate 


  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    TF_VAR_DOMAIN_NAME=${DOMAIN_NAME} \
    TF_VAR_VPC_NAME=${VPC_NAME} \
    TF_VAR_ECS_CLUSTER_NAME=${CLUSTER_NAME} \
    terraform -chdir=./services plan
}

function apply() {
  echo "aws account ${AWS_ACCOUNT} ${DOCKER_BUILD_TAG}"
  echo "${DOMAIN_NAME}"
  
  # TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init -chdir=./services -backend-config="${BACKEND_CONFIG}"
  

  # TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  #   TF_VAR_AWS_REGION="ap-south-1" \
  #   TF_VAR_PARAM_PREFIX="talon/apiserver" \
  #   TF_VAR_ENVIRONMENT="prod" \
  #   TF_VAR_APP_NAME="${APP_NAME}" \
  #   TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
  #   terraform validate

  # TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
  #   TF_VAR_AWS_REGION="ap-south-1" \
  #   TF_VAR_PARAM_PREFIX="talon/apiserver" \
  #   TF_VAR_ENVIRONMENT="prod" \
  #   TF_VAR_APP_NAME="${APP_NAME}" \
  #   TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
  #   terraform plan

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    TF_VAR_DOMAIN_NAME=${DOMAIN_NAME} \
    TF_VAR_VPC_NAME=${VPC_NAME} \
    TF_VAR_ECS_CLUSTER_NAME=${CLUSTER_NAME} \
    terraform -chdir=./services apply
}


function destroy() {
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config="${BACKEND_CONFIG}"

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    TF_VAR_DOMAIN_NAME=${DOMAIN_NAME} \
    TF_VAR_VPC_NAME=${VPC_NAME} \
    terraform destroy -chdir=./services
}


function show() {
  TF_VAR_AWS_PROFILE=${AWS_PROFILE} terraform init -backend-config="${BACKEND_CONFIG}"

  TF_VAR_AWS_ACCOUNT=${AWS_ACCOUNT} \
    TF_VAR_AWS_REGION="ap-south-1" \
    TF_VAR_PARAM_PREFIX="talon/apiserver" \
    TF_VAR_ENVIRONMENT="prod" \
    TF_VAR_APP_NAME="${APP_NAME}" \
    TF_VAR_AWS_PROFILE=${AWS_PROFILE} \
    TF_VAR_DOMAIN_NAME=${DOMAIN_NAME} \
    TF_VAR_VPC_NAME=${VPC_NAME} \
    terraform show -chdir=./services
}


__ACTIONS__=":apply:show:destroy:plan:"
ACTION="show"

usage() { echo "Usage: $0 [-a <show|apply|destroy|plan>]" 1>&2; exit 1; }

while getopts ":a:" arg; do
  case "${arg}" in
    a)
      ACTION="${OPTARG}"
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

if [[ ! "${__ACTIONS__}" =~ ":${ACTION}:" ]]; then
  echo "invalid actions"
  usage
  exit 1
fi

echo "Running terraform ${ACTION}"

case "$ACTION" in
  "show")
    show
    ;;
  "plan")
    plan
    ;;
  "apply")
    apply
    ;;
  "destroy")
    destroy
    ;;
  *)
    echo "invalid action $ACTION"
    exit 1
esac

