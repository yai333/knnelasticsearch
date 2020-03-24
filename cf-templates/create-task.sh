#!/bin/bash

set -ex

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

AWS_DEFAULT_REGION="ap-southeast-2"
AWS_PROFILE="default"

cluster_stack_output=$(aws --profile "${AWS_PROFILE}" --region "${AWS_DEFAULT_REGION}" \
    cloudformation describe-stacks --stack-name "knn-search-infra" \
    | jq '.Stacks[].Outputs[]')

cluster_name=($(echo $cluster_stack_output \
    | jq -r 'select(.OutputKey == "ClusterName") | .OutputValue'))

task_role_arn=($(echo $cluster_stack_output \
    | jq -r 'select(.OutputKey == "TaskIamRole") | .OutputValue'))

execution_role_arn=($(echo $cluster_stack_output \
    | jq -r 'select(.OutputKey == "TaskExecutionIamRole") | .OutputValue'))

ecs_service_log_group=($(echo $cluster_stack_output \
    | jq -r 'select(.OutputKey == "LogGroup") | .OutputValue'))

envoy_log_level="debug"

IMAGE="$( aws ecr describe-repositories --repository-name knnsearch --region ${AWS_DEFAULT_REGION} --profile ${AWS_PROFILE} --query 'repositories[0].repositoryUri' --output text)"

EFS_ID=$(aws  --region ap-southeast-2 \
    cloudformation describe-stacks --stack-name knn-search-infra \
      --query 'Stacks[0].Outputs[?OutputKey==`FileSystemID`].OutputValue' \
      --output text)
#Api v1 Task Definition
task_def_json=$(jq -n \
    --arg IMAGE $IMAGE \
    --arg SERVICE_LOG_GROUP $ecs_service_log_group \
    --arg TASK_ROLE_ARN $task_role_arn \
    --arg EXECUTION_ROLE_ARN $execution_role_arn \
    --arg FILE_SYSTEM_ID $EFS_ID \
    -f "${DIR}/task-definition.json")


task_def_arn=$(aws --profile "${AWS_PROFILE}" --region "${AWS_DEFAULT_REGION}" \
    ecs register-task-definition \
    --cli-input-json "${task_def_json}" \
    --query [taskDefinition.taskDefinitionArn] --output text)

#update ECS servcie if there is new version of task definiton
aws ecs update-service  --profile "${AWS_PROFILE}" --region "${AWS_DEFAULT_REGION}" \
                        --cluster ${cluster_name} \
                        --service knn-search \
                        --task-definition ${task_def_arn} \
                        --desired-count 1
