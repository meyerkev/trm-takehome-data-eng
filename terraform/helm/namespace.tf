resource "kubernetes_namespace" "trm_takehome" {
  metadata {
    name = "trm"
  }
}