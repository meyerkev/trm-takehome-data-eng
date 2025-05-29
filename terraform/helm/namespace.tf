resource "kubernetes_namespace" "trm_takehome" {
  metadata {
    name = "trm"
  }
}

# Validate that this exists
data "aws_ssm_parameter" "infura_api_key" {
  name = "/trm/infura/api_key"
}

resource "kubernetes_secret" "infura_api_key" {
  metadata {
    name = "infura-api-key"
    namespace = resource.kubernetes_namespace.trm_takehome.metadata[0].name
  }
  data = {
    "INFURA_API_KEY" = data.aws_ssm_parameter.infura_api_key.value
  }
}