#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
STACK_NAME="knn-search-infra"

aws cloudformation deploy \
    --stack-name "${STACK_NAME}" \
    --template-file "${DIR}/infra.yaml" \
    --region ap-southeast-2 \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides ECSAMI="/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
