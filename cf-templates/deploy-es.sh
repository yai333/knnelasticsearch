#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PARENT_STACK_NAME="knn-search-infra"
REGION="ap-southeast-2"


aws cloudformation deploy \
    --stack-name "knn-search-elasticsearch" \
    --template-file "${DIR}/es.yaml" \
    --region ${REGION} \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
    StackName="${PARENT_STACK_NAME}"
