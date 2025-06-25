cluster_name = "my-first-sks-cluster"

tenants = {
  tenant-a = {
    namespace_name = "tenant-a"
    db_name        = "tenanta-db"
    secret_name    = "tenanta-db-secret"
    exoscale_zone  = "at-vie-2"
  },
  tenant-b = {
    namespace_name = "tenant-b"
    db_name        = "tenantb-db"
    secret_name    = "tenantb-db-secret"
    exoscale_zone  = "at-vie-2"
  }
}