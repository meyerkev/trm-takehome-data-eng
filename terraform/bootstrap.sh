#!/bin/bash

# Call terraform in ecr/ and then in eks/
# Leave helm/ alone for now.
cd $(dirname $0) 

# Generate Terraform state init TF_INIT_ARGS for S3
TF_INIT_ARGS=""
if [ ! -z "$TFSTATE_BUCKET" ]; then
  TF_INIT_ARGS="-backend-config=bucket=$TFSTATE_BUCKET"
fi
if [ ! -z "$TFSTATE_REGION" ]; then
  TF_INIT_ARGS="$TF_INIT_ARGS -backend-config=region=$TFSTATE_REGION"
fi

# Call terraform in ecr/
cd ecr/
terraform init $TF_INIT_ARGS
terraform apply -auto-approve

# Call terraform in eks/
cd ../eks/
terraform init $TF_INIT_ARGS
terraform apply -auto-approve

# There is an output in eks/ that is the kubeconfig generator from EKS
mkdir -p ~/.kube
kubeconfig_command=$(terraform output -raw kubeconfig_command)
$kubeconfig_command

