variable "namespace_name_oauth2" {
  type        = string
  description = "Name of oauth2 namespace"
}

variable "oauth2_client_id" {
  sensitive   = true
  type        = string
  description = "Client Id of oauth2 authenticator"
}

variable "oauth2_client_secret" {
  sensitive   = true
  type        = string
  description = "Client Secret of oauth2 authenticator"
}

variable "oauth2_cookie_secret"{
  sensitive   = true
  type        = string
  description = "Cookie Secret for oauth2 proxy"
}