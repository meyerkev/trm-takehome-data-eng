#setup github actions to push to ECR

# enable github oidc provider

# Get the thumbprint for the github oidc provider
data "tls_certificate" "github_oidc" {
    url = "https://token.actions.githubusercontent.com"
}

# Create the github oidc provider
resource "aws_iam_openid_connect_provider" "github_oidc" {
    url = "https://token.actions.githubusercontent.com"
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = [for cert in data.tls_certificate.github_oidc.certificates : cert.sha1_fingerprint ]
}

#create role to allow github actions to push to ECR

resource "aws_iam_role" "github_actions_role" {
    name = "github-actions-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRoleWithWebIdentity"
                Effect = "Allow"
                Principal = {
                    "Federated" = aws_iam_openid_connect_provider.github_oidc.arn
                }
                Condition = {
                    "StringEquals" = {
                        "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
                    },
                    "StringLike" = {
                        "token.actions.githubusercontent.com:sub" = "repo:meyerkev/trm-takehome-data-eng:*"
                    }
                }
            }
        ]
    })  
}

resource "aws_iam_role" "github_actions_role_terraform" {
    name = "github-actions-role-terraform"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRoleWithWebIdentity" 
                Effect = "Allow"
                Principal = {
                    "Federated" = aws_iam_openid_connect_provider.github_oidc.arn
                }
                Condition = {
                    "StringEquals" = {
                        "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
                    },
                    "StringLike" = {
                        "token.actions.githubusercontent.com:sub" = "repo:meyerkev/trm-takehome-data-eng:*"
                    }
                }
            }
        ]
    })
}

# TODO: Terraform runner should not be admin for least access reasons, but in the interests of time, it is. 
resource "aws_iam_role_policy_attachment" "github_actions_attachment_terraform" {
    role = aws_iam_role.github_actions_role_terraform.name
    policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#create policy to allow github actions to push to ECR

resource "aws_iam_policy" "github_actions_policy" {
    name = "github-actions-policy"  
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "ecr:GetAuthorizationToken",
                    "ecr:BatchCheckLayerAvailability",
                    "ecr:GetDownloadUrlForLayer",
                    "ecr:GetRepositoryPolicy",
                    "ecr:DescribeRepositories",
                    "ecr:ListImages",
                    "ecr:DescribeImages",
                    "ecr:BatchGetImage",
                    "ecr:InitiateLayerUpload",
                    "ecr:UploadLayerPart",
                    "ecr:CompleteLayerUpload",
                    "ecr:PutImage"
                ]
                Resource = "*"
            }
        ]
    })  
}

#attach policy to role

resource "aws_iam_role_policy_attachment" "github_actions_attachment" {
    role = aws_iam_role.github_actions_role.name
    policy_arn = aws_iam_policy.github_actions_policy.arn
}