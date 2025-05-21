
# Would I do this under any circumstances if I had more than 3 hours?  
## No
terraform {
  required_version = "1.12.0"
  backend "s3" {
    bucket = "meyerkev-terraform-state"
    key = "test.tfstate"
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
  region = "us-east-2"
  default_tags {
    tags = {
      Terraform = "true"
    }
  }
}

data "aws_caller_identity" "current" {}

output "identity" {
  value = data.aws_caller_identity.current
}
