output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}

output "github_actions_role_terraform_arn" {
  value = aws_iam_role.github_actions_role_terraform.arn
}

output "thumbprints" {
  value = [for cert in data.tls_certificate.github_oidc.certificates : cert.sha1_fingerprint ]
}