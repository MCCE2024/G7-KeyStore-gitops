variable "cluster_name" {
  type        = string
  description = "Name of the cluster"
}

variable "exoscale_key" {
  type        = string
  description = "Exoscale API key"
}

variable "exoscale_secret" {
  type        = string
  description = "Exoscale API secret"
  sensitive   = false
}

variable "exoscale_zone" {
  type        = string
  description = "Exoscale zone to use"
  default     = "at-vie-2"
}

variable "sks_service_level" {
  type        = string
  description = "Service level for the SKS cluster"
  default     = "starter"
}

variable "tenants" {
  description = "Map of tenants"
  type = map(object({
    namespace_name = string
    db_name        = string
    secret_name    = string
    exoscale_zone  = string
  }))
}

variable "namespace_name_ingress" {
  type        = string
  description = "Name of nginx namespace"
}

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

variable "oauth2_cookie_secret" {
  sensitive   = true
  type        = string
  description = "Cookie Secret for oauth2 proxy"
}

variable "git_username" {
  type        = string
  description = "Github Username secret"
  sensitive   = true
}

variable "git_token" {
  type        = string
  description = "Github token secret"
  sensitive   = true
}
