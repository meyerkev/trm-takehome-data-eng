#setup github actions to push to ECR

# enable github oidc provider

resource "aws_iam_openid_connect_provider" "github_oidc" {
    url = "https://token.actions.githubusercontent.com"
    client_id_list = ["sts.amazonaws.com"]
    thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
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

#create policy to allow github actions to push to ECR

resource "aws_iam_policy" "github_actions_policy" {
    name = "github-actions-policy"  
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "ecr:*"
                Effect = "Allow"
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