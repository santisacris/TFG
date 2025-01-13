resource "azurerm_private_endpoint" "storage_sql_private_endpoint" {
  name                = "storage-sql-private-endpoint"
  location            = "westeurope"
  resource_group_name = "IaC-Developers"
  subnet_id           = azurerm_subnet.storage-subnet.id  # Subnet de la capa storage

  private_service_connection {
    name                           = "storage-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.storage-sql.id
    subresource_names              = ["sqlServer"]  # Esto especifica el servidor SQL
    is_manual_connection           = false
  }
}

resource "azurerm_private_dns_zone" "sql_dns_zone" {
  name                = "privatelink.database.windows.net"
  resource_group_name = "IaC-Developers"
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql_dns_link" {
  name                  = "sql-dns-link"
  private_dns_zone_name = azurerm_private_dns_zone.sql_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.main-vnet.id
  resource_group_name = "IaC-Developers"
}

resource "azurerm_private_dns_a_record" "sql_a_record" {
  name                = azurerm_mssql_server.storage-sql.name
  zone_name           = azurerm_private_dns_zone.sql_dns_zone.name
  resource_group_name = "IaC-Developers"
  ttl                 = 300
  records             = [azurerm_private_endpoint.storage_sql_private_endpoint.private_service_connection[0].private_ip_address]
}


resource "azurerm_mssql_server" "storage-sql" {
  name                         = "s-db-sqlserver"
  resource_group_name          = "IaC-Developers"
  location                     = "westeurope"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "AdminPassword123!"

  public_network_access_enabled = false # Desactiva el acceso público
}

resource "azurerm_mssql_database" "storage-db" {
  name         = "s-db-sqldatabase"
  server_id    = azurerm_mssql_server.storage-sql.id
  collation    = "SQL_Latin1_General_CP1_CI_AS"
  license_type = "LicenseIncluded"
  max_size_gb  = 2
  sku_name     = "S0"
  enclave_type = "VBS"

  tags = {
    foo = "bar"
    Owner       = "Santi" 
    CostCenter  = "CC12345"
    Proyect     = "WebAppDeployment"
    Application = "StorageDataBase"
    Environment = "Production"
  }

  # To prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = true
  }
}