terraform {
  required_providers {
    exoscale = {
      source = "exoscale/exoscale"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

# Kubernetes Namespace für den Mandanten
resource "kubernetes_namespace" "oauth2proxy_ns" {
  metadata {
    name = var.namespace_name_oauth2
  }
}

resource "helm_release" "oauth2_proxy" {
  name       = "oauth2-proxy"
  repository = "https://oauth2-proxy.github.io/manifests"
  chart      = "oauth2-proxy"
  namespace  = var.namespace_name_oauth2

  values = [
    yamlencode({
      config = {
        clientID     = var.oauth2_client_id
        clientSecret = var.oauth2_client_secret
        cookieSecret = var.oauth2_cookie_secret
      }

      extraArgs = {
        provider     = "github"
        upstream     = "file:///dev/null"
        http-address = "0.0.0.0:4180"
        redirect-url = "http://fhb-key.store/oauth2/callback"
        cookie-secure = false
        email-domain = "*"
      }

      ingress = {
        enabled     = true
        className   = "nginx"
        annotations = {}
        path        = "/oauth2"
        pathType    = "Prefix"
        hosts       = ["fhb-key.store"]
        servicePort = "http" # oder 4180, je nach Chart
      }
    })
  ]
}
