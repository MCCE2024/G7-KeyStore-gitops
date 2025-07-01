cluster_name           = "key-store-cluster"
namespace_name_ingress = "ingress"
namespace_name_oauth2  = "oauth-2"

tenants = {
  tenant-a = {
    namespace_name = "tenant-a"
    db_name        = "tenant-a-db"
    secret_name    = "tenant-a-db-secret"
    exoscale_zone  = "at-vie-2"
  }
}
