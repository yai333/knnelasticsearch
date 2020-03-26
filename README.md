# Overview

This is sample project shows how to build a scalable similarity questions search Engine using Amazon Sagemaker, Amazon Elasticsearch, Amazon Elastic File System (EFS) and Amazon ECS.

https://towardsdatascience.com/building-a-k-nn-similarity-search-engine-using-amazon-elasticsearch-and-sagemaker-98df18d883bd

## Jupyter notebook

You can use `knn-search.ipynb` to transform and index dataset to Elasticsearch.

## Prerequisites

The following must be done before following this guide:

- Setup an AWS account.
- Configure the AWS CLI with user credentials.
- Install AWS CLI.
- jq.

## Build docker image

Create a ECR repo in ECS console, copy repo url and build docker.

```
$docker build -t YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/knnsearch .
```

## Push docker image to ECR

```
$eval $(aws ecr get-login --region ap-southeast-2 --no-include-email)

$docker push YOUR_ACCOUNT_ID.dkr.ecr.YOUR_REGION.amazonaws.com/knnsearch

```

## Deploy infrastructure stack

```
$cd cf-templates
$bash deploy-infra.sh
```

## Create Container task definition

```
$bash create-task.sh
```

## Deploy ECS service stack

```
$bash deploy-service.sh

```
