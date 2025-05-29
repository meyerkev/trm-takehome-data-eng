# Kevin Meyer's TRM Takehome

## A preemptive note about terraform state

We use S3 as our backing store using a bucket. To use your bucket instead of my defaults, `terraform init` should actually be:

```bash
export TFSTATE_BUCKET=<your bucket>
export TFSTATE_REGION=<your bucket region>
terraform init \
-backend-config="bucket=${TFSTATE_BUCKET}" \
-backend-config="region=${TFSTATE_REGION}"
```

## Dependencies

I had no major issues, but I was also doing this on a Mac laptop that I've been using for development for several years.  

As a result, this may be incomplete.  

```bash
brew install tfenv kubectl awscli helm

# Grab Terraform
# Install the versions we need for each subdirectory
for dir in terraform/*/; do
  if [ -f "${dir}.terraform-version" ]; then
    tfenv install $(cat "${dir}.terraform-version")
  fi
done

# Use admin creds, since we'll need this to run the bootstrap of ECR and EKS
aws configure
```

You'll need Docker as well

```shell
brew install --cask docker

# Follow the admin prompts to get Docker fully installed on your system
open -a "Docker Desktop"
```

## Local development

We have a working Makefile so let's use it.  

```bash
cd src/
make docker-build
make up
curl localhost:4000/address/exposure/direct

# When done testing
made down
```

## Setting up the cloud environment

```bash
export TFSTATE_BUCKET
export TFSTATE_REGION
./terraform/bootstrap.sh
```

This will setup our ECR repository and EKS.  

## Local development of the Helm

```bash
cd terraform/helm/
terraform init \
-backend-config="bucket=${TFSTATE_BUCKET}" \
-backend-config="region=${TFSTATE_REGION}"
terraform apply
```

Since we haven't picked up semantic-

## CI

We have a push to master CI build that pushes to master anytime we merge a PR.  This takes approximately 10 minutes to deploy because it's multi-architecture.  Single-architecture drops it to 2. 

When we push to master, this will generate a new docker image and then force a helm rollout.  

To test: 

```bash
meyerkev@Kevins-MacBook-Pro-2 helm % kubectl get ingress --namespace trm
NAME                                  CLASS   HOSTS   ADDRESS                                                              PORTS   AGE
trm-deployment-trm-deployment-chart   alb     *       k8s-trm-trmdeplo-95dc2494ec-1845807862.us-east-2.elb.amazonaws.com   80      143m

# Our magic LB is k8s-trm-trmdeplo-95dc2494ec-1845807862.us-east-2.elb.amazonaws.com
## On first boot, this may take <5 minutes to provision>
meyerkev@Kevins-MacBook-Pro-2 helm % curl k8s-trm-trmdeplo-95dc2494ec-1845807862.us-east-2.elb.amazonaws.com/address/balance/0xc94770007dda54cF92009BFF0dE90c06F603a09f
{"balance":1.2047354718e-05}
```

### Known modifications

In `.github/workflows/ci.yaml`, we have hard-coded my account ID `AWS_ACCOUNT_ID: 386145735201`.  If you want CI to work, this will need to be modified.  Since the easiest way to force an image build and helm rollout is to push to the master branch

Alternatively, you can run:

```
cd src/
make AWS_ACCOUNT_ID=<your id> AWS_REGION=<your region> IMAGE_TAG=master docker-build push
cd ../terraform/helm
terraform apply
```

to force a push to a bootstrapped EKS and ECR setup.  




