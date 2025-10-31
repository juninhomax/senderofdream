# Outputs Terraform pour l'infrastructure Laravel Azure

# Informations du groupe de ressources
output "resource_group_name" {
  description = "Nom du groupe de ressources"
  value       = local.resource_group_name
}

output "resource_group_location" {
  description = "Région du groupe de ressources"
  value       = local.resource_group_location
}

# Informations Azure Container Registry
output "acr_name" {
  description = "Nom de l'Azure Container Registry"
  value       = azurerm_container_registry.main.name
}

output "acr_login_server" {
  description = "URL du serveur de connexion ACR"
  value       = azurerm_container_registry.main.login_server
}

output "acr_admin_username" {
  description = "Nom d'utilisateur administrateur ACR (auto-generated)"
  value       = azurerm_container_registry.main.admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Mot de passe administrateur ACR (auto-generated)"
  value       = azurerm_container_registry.main.admin_password
  sensitive   = true
}

# Informations MySQL
output "mysql_server_name" {
  description = "Nom du serveur MySQL"
  value       = azurerm_mysql_flexible_server.main.name
}

output "mysql_server_fqdn" {
  description = "FQDN du serveur MySQL"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "mysql_database_name" {
  description = "Nom de la base de données MySQL"
  value       = azurerm_mysql_flexible_database.app_database.name
}

output "mysql_admin_username" {
  description = "Nom d'utilisateur administrateur MySQL"
  value       = azurerm_mysql_flexible_server.main.administrator_login
}

output "mysql_admin_password" {
  description = "Mot de passe administrateur MySQL"
  value       = random_password.mysql_admin_password.result
  sensitive   = true
}

output "mysql_app_username" {
  description = "Nom d'utilisateur de l'application MySQL"
  value       = var.mysql_app_username
}

output "mysql_app_password" {
  description = "Mot de passe de l'application MySQL"
  value       = random_password.mysql_app_password.result
  sensitive   = true
}

# Informations App Service
output "app_service_name" {
  description = "Nom de l'App Service"
  value       = azurerm_linux_web_app.main.name
}

output "app_service_default_hostname" {
  description = "Nom d'hôte par défaut de l'App Service"
  value       = azurerm_linux_web_app.main.default_hostname
}

output "app_service_url" {
  description = "URL complète de l'application"
  value       = "https://${azurerm_linux_web_app.main.default_hostname}"
}

output "app_service_plan_name" {
  description = "Nom du plan App Service"
  value       = azurerm_service_plan.main.name
}

# Informations de connexion pour les scripts de déploiement
output "docker_build_command" {
  description = "Commande pour builder l'image Docker"
  value       = "docker build -t ${azurerm_container_registry.main.login_server}/${var.docker_image_name}:${var.docker_image_tag} ."
}

output "docker_push_command" {
  description = "Commande pour pusher l'image Docker"
  value       = "docker push ${azurerm_container_registry.main.login_server}/${var.docker_image_name}:${var.docker_image_tag}"
}

output "acr_login_command" {
  description = "Commande pour se connecter à ACR"
  value       = "docker login ${azurerm_container_registry.main.login_server}"
}

# Laravel App Key
output "laravel_app_key" {
  description = "Clé d'application Laravel"
  value       = "base64:${base64encode(random_password.laravel_app_key.result)}"
  sensitive   = true
}

# Variables d'environnement pour l'application
output "app_environment_variables" {
  description = "Variables d'environnement de l'application"
  value = {
    DB_CONNECTION = "mysql"
    DB_HOST       = azurerm_mysql_flexible_server.main.fqdn
    DB_PORT       = "3306"
    DB_DATABASE   = azurerm_mysql_flexible_database.app_database.name
    DB_USERNAME   = var.mysql_app_username
    MYSQL_ATTR_SSL_CA = "/opt/ssl/DigiCertGlobalRootCA.crt.pem"
    APP_ENV       = var.laravel_app_env
    APP_DEBUG     = var.laravel_app_debug
  }
  sensitive = false
}

# Informations de déploiement
output "deployment_info" {
  description = "Informations de déploiement"
  value = {
    resource_group = local.resource_group_name
    location       = local.resource_group_location
    acr_url        = azurerm_container_registry.main.login_server
    app_url        = "https://${azurerm_linux_web_app.main.default_hostname}"
    mysql_host     = azurerm_mysql_flexible_server.main.fqdn
  }
}

# Commandes utiles pour la gestion post-déploiement
output "useful_commands" {
  description = "Commandes utiles pour la gestion"
  value = {
    view_app_logs    = "az webapp log tail --name ${azurerm_linux_web_app.main.name} --resource-group ${local.resource_group_name}"
    restart_app      = "az webapp restart --name ${azurerm_linux_web_app.main.name} --resource-group ${local.resource_group_name}"
    connect_mysql    = "mysql -h ${azurerm_mysql_flexible_server.main.fqdn} -u ${var.mysql_app_username} -p"
    scale_app        = "az appservice plan update --name ${azurerm_service_plan.main.name} --resource-group ${local.resource_group_name} --sku [NEW_SKU]"
  }
}
