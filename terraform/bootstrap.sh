#!/bin/bash

# Call terraform in ecr/ and then in eks/
# Leave helm/ alone for now.
cd $(dirname $0) 

# Generate Terraform state init args for S3


# Call terraform in ecr/
cd ecr/
terraform init
terraform apply -auto-approve

# Call terraform in eks/
cd ../eks/
terraform init
terraform apply -auto-approve

# There is an output in eks/ that is the kubeconfig generator from EKS
mkdir -p ~/.kube
kubeconfig_command=$(terraform output -raw kubeconfig_command)
$kubeconfig_command

