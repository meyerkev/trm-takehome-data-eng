// We need a private ECR repo to store our Docker images
// This is a simple Terraform module to create a private ECR repo
// and configure the necessary IAM policies for the ECR repo

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = var.repository_name

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "interview"
  }
}