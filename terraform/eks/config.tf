
# Would I do this under any circumstances if I had more than 3 hours?  
## No
terraform {
  required_version = "1.12.0"
  # Really you ought to clean this up and use a remote backend, but this is an interview and I spin this up A LOT, then run aws-nuke on the account
  backend "s3" {
    bucket = "meyerkev-terraform-state"
    key = "test-interview.tfstate"
    region = "us-east-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    # This requires the awscli to be installed locally where Terraform is executed
    args = ["eks", "get-token", "--region", var.region,  "--cluster-name", module.eks.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1"
      args        = ["eks", "get-token", "--region", var.region, "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}
