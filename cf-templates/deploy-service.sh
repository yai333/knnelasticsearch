#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PARENT_STACK_NAME="knn-search-infra"
REGION="ap-southeast-2"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

TASK_DEF_ARN=$(aws ecs list-task-definitions --family-prefix knn-search \
--region ${REGION} --profile default \
--sort DESC \
--query 'taskDefinitionArns[0]' --output text)


aws cloudformation deploy \
    --stack-name "knn-search-ecs" \
    --template-file "${DIR}/service.yaml" \
    --region ${REGION} \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
    StackName="${PARENT_STACK_NAME}" \
    TaskDefinition="${TASK_DEF_ARN}"
