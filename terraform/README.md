# Kevin Meyer's TRM Takehome

## Dependencies

I had no issues, but I was also doing this on a Mac laptop that I've been using for development for several years. 
Off the top of my head, I would guess:

`brew install tfenv kubectl`

You'll need Docker as well

## Local development

We have a working Makefile so let's use it.  

```bash
cd src/
make docker-build
make up
curl localhost:4000/address/exposure/direct
```

## Setting up the cloud environment

```bash
./terraform/bootstrap.sh
```

This will setup our ECR repository and EKS. 

## CI

We have a push to master CI build that pushes to master anytime we merge a PR.  This takes approximately 10 minutes to deploy because it's multi-architecture.  Single-architecture drops it to 2. 

## Helm and deployments

<TODO TODO TODO>: We have a directory 



