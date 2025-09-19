# Configuration Terraform pour l'infrastructure Laravel Azure
terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# Configuration du provider Azure avec subscription spécifique
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.azure_subscription_id
}

# Variables locales pour la configuration
locals {
  project_name = var.project_name
  environment  = var.environment
  location     = var.location
  
  # Tags communs pour toutes les ressources
  common_tags = {
    Project     = local.project_name
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
  
  # Noms des ressources avec convention de nommage
  mysql_server_name  = "mysql-${local.project_name}-${local.environment}"
  app_service_name   = "app-${local.project_name}-${local.environment}"
  app_service_plan_name = "plan-${local.project_name}-${local.environment}"
  acr_name = "acr${replace(local.project_name, "-", "")}${local.environment}"
  
  # Chemin du projet pour les scripts
  project_path = "${path.root}/.."
}

# Utilisation du groupe de ressources existant ou création si nécessaire
data "azurerm_resource_group" "existing" {
  count = var.use_existing_resource_group ? 1 : 0
  name  = "rg-stg_10"
}

resource "azurerm_resource_group" "main" {
  count    = var.use_existing_resource_group ? 0 : 1
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  
  tags = local.common_tags
}

locals {
  resource_group_name = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].name : azurerm_resource_group.main[0].name
  resource_group_location = var.use_existing_resource_group ? data.azurerm_resource_group.existing[0].location : azurerm_resource_group.main[0].location
}

# Génération des mots de passe MySQL (sans caractères spéciaux problématiques)
resource "random_password" "mysql_admin_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

resource "random_password" "mysql_app_password" {
  length  = 16
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Génération de la clé Laravel
resource "random_password" "laravel_app_key" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true
}

# Azure Container Registry
resource "azurerm_container_registry" "main" {
  name                = local.acr_name
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  sku                 = var.acr_sku
  admin_enabled       = true
  
  tags = merge(local.common_tags, {
    Service = "ContainerRegistry"
  })
}

# Azure Database for MySQL Flexible Server
resource "azurerm_mysql_flexible_server" "main" {
  name                = local.mysql_server_name
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  
  administrator_login    = var.mysql_admin_username
  administrator_password = random_password.mysql_admin_password.result
  
  backup_retention_days        = var.mysql_backup_retention_days
  geo_redundant_backup_enabled = false
  
  sku_name   = var.mysql_sku_name
  version    = var.mysql_version
  
  storage {
    auto_grow_enabled = true
    size_gb          = var.mysql_storage_gb
  }
  
  tags = merge(local.common_tags, {
    Service = "MySQL"
  })
}

# Configuration MySQL - SSL obligatoire
resource "azurerm_mysql_flexible_server_configuration" "require_secure_transport" {
  name                = "require_secure_transport"
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  value               = "ON"
}

# Règle de pare-feu pour permettre les services Azure
resource "azurerm_mysql_flexible_server_firewall_rule" "azure_services" {
  name                = "AllowAzureServices"
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# Règle de pare-feu pour permettre toutes les connexions (temporaire pour setup)
resource "azurerm_mysql_flexible_server_firewall_rule" "allow_all_setup" {
  name                = "AllowAllForSetup"
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

# Base de données pour l'application
resource "azurerm_mysql_flexible_database" "app_database" {
  name                = var.mysql_database_name
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mysql_flexible_server.main.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_ci"
}


# Plan App Service Linux
resource "azurerm_service_plan" "main" {
  name                = local.app_service_plan_name
  resource_group_name = local.resource_group_name
  location            = local.resource_group_location
  
  os_type  = "Linux"
  sku_name = var.app_service_sku
  
  tags = merge(local.common_tags, {
    Service = "AppServicePlan"
  })
}

# App Service Linux avec conteneur Docker
resource "azurerm_linux_web_app" "main" {
  name                = local.app_service_name
  resource_group_name = local.resource_group_name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id
  
  # Configuration du conteneur Docker
  site_config {
    always_on = var.app_service_always_on
    
    application_stack {
      docker_image     = "${azurerm_container_registry.main.login_server}/${var.docker_image_name}"
      docker_image_tag = var.docker_image_tag
    }
    
    container_registry_use_managed_identity = false
  }
  
  # Authentification Container Registry
  app_settings = merge({
    # Configuration base de données
    DB_CONNECTION = "mysql"
    DB_HOST       = azurerm_mysql_flexible_server.main.fqdn
    DB_DATABASE   = azurerm_mysql_flexible_database.app_database.name
    DB_USERNAME   = var.mysql_admin_username
    DB_PASSWORD   = random_password.mysql_admin_password.result
    
    # Configuration SSL MySQL
    MYSQL_ATTR_SSL_CA = "/opt/ssl/DigiCertGlobalRootCA.crt.pem"
    
    # Configuration Laravel
    APP_ENV   = var.laravel_app_env
    APP_DEBUG = var.laravel_app_debug
    APP_KEY   = "base64:${base64encode(random_password.laravel_app_key.result)}"
    
    # Configuration Docker
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    WEBSITES_PORT                       = "80"
  }, {
    # Authentification Container Registry
    DOCKER_REGISTRY_SERVER_URL      = "https://${azurerm_container_registry.main.login_server}"
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.main.admin_username
    DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.main.admin_password
  })
  
  # Configuration HTTPS
  https_only = true
  
  tags = merge(local.common_tags, {
    Service = "WebApp"
  })
  
  # Dépendances explicites
  depends_on = [
    azurerm_container_registry.main,
    azurerm_mysql_flexible_server.main,
    azurerm_mysql_flexible_database.app_database,
    null_resource.docker_build_push
  ]
}

# Construction et push de l'image Docker
resource "null_resource" "docker_build_push" {
  triggers = {
    dockerfile_hash = filemd5("${local.project_path}/Dockerfile")
    source_hash     = sha1(join("", [for f in fileset("${local.project_path}", "**/*.php") : filesha1("${local.project_path}/${f}")]))
    acr_server      = azurerm_container_registry.main.login_server
  }

  provisioner "local-exec" {
    command = <<-EOT
      az acr login --name ${azurerm_container_registry.main.name}
      docker build -t ${azurerm_container_registry.main.login_server}/${var.docker_image_name}:${var.docker_image_tag} ${local.project_path}
      docker push ${azurerm_container_registry.main.login_server}/${var.docker_image_name}:${var.docker_image_tag}
    EOT
    
    working_dir = local.project_path
  }

  depends_on = [azurerm_container_registry.main]
}

# Note: Utilisation de l'utilisateur admin MySQL directement pour Laravel
# Cela évite les problèmes de création d'utilisateur supplémentaire

# Configuration App Service
resource "null_resource" "app_service_config" {
  triggers = {
    docker_image = "${azurerm_container_registry.main.login_server}/${var.docker_image_name}:${var.docker_image_tag}"
    mysql_server = azurerm_mysql_flexible_server.main.fqdn
  }


  depends_on = [
    azurerm_mysql_flexible_server.main,
    azurerm_mysql_flexible_database.app_database,
    azurerm_linux_web_app.main,
    null_resource.docker_build_push
  ]
}

# Slot de déploiement pour staging (optionnel)
resource "azurerm_linux_web_app_slot" "staging" {
  count           = var.create_staging_slot ? 1 : 0
  name            = "staging"
  app_service_id  = azurerm_linux_web_app.main.id
  
  site_config {
    always_on = false
    
    application_stack {
      docker_image     = "${azurerm_container_registry.main.login_server}/${var.docker_image_name}"
      docker_image_tag = "staging"
      docker_registry_url      = "https://${azurerm_container_registry.main.login_server}"
      docker_registry_username = azurerm_container_registry.main.admin_username
      docker_registry_password = azurerm_container_registry.main.admin_password
    }
  }
  
  app_settings = azurerm_linux_web_app.main.app_settings
  
  tags = merge(local.common_tags, {
    Service = "WebApp"
    Slot    = "Staging"
  })
}
