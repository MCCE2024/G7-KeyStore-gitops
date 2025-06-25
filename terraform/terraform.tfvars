cluster_name         = "my-first-sks-cluster"
namespace_name_nginx = "ingress-namespace"

tenants = {
  tenant-a = {
    namespace_name = "tenant-a"
    db_name        = "tenant-a-db"
    secret_name    = "tenant-a-db-secret"
    exoscale_zone  = "at-vie-2"
  },
  tenant-b = {
    namespace_name = "tenant-b"
    db_name        = "tenant-b-db"
    secret_name    = "tenant-b-db-secret"
    exoscale_zone  = "at-vie-2"
  },
  tenant-c = {
    namespace_name = "tenant-c"
    db_name        = "tenant-c-db"
    secret_name    = "tenant-c-db-secret"
    exoscale_zone  = "at-vie-2"
  }
}