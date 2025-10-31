# Variables Terraform pour l'infrastructure Laravel Azure

# Variables générales du projet
variable "project_name" {
  description = "Nom du projet (utilisé dans les noms de ressources)"
  type        = string
  default     = "sampleappstg10max"
  
  validation {
    condition     = can(regex("^[a-z0-9]+$", var.project_name))
    error_message = "Le nom du projet ne peut contenir que des lettres minuscules et des chiffres."
  }
}

variable "environment" {
  description = "Environnement de déploiement"
  type        = string
  default     = "prod"
  
  validation {
    condition     = contains(["dev", "staging", "prod", "tf"], var.environment)
    error_message = "L'environnement doit être dev, staging, prod ou tf."
  }
}

variable "location" {
  description = "Région Azure pour le déploiement"
  type        = string
  default     = "France Central"
}

# Configuration Azure
variable "azure_subscription_id" {
  description = "ID de la subscription Azure à utiliser"
  type        = string
  default     = "6b9318b1-2215-418a-b0fd-ba0832e9b333"
}

# Configuration du groupe de ressources
variable "use_existing_resource_group" {
  description = "Utiliser un groupe de ressources existant"
  type        = bool
  default     = true
}

# Variables Azure Container Registry
variable "acr_sku" {
  description = "SKU de l'Azure Container Registry"
  type        = string
  default     = "Standard"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "Le SKU ACR doit être Basic, Standard ou Premium."
  }
}

# Variables MySQL
variable "mysql_admin_username" {
  description = "Nom d'utilisateur administrateur MySQL"
  type        = string
  default     = "adminuser"
}

variable "mysql_app_username" {
  description = "Nom d'utilisateur de l'application MySQL"
  type        = string
  default     = "app_user"
}

variable "mysql_database_name" {
  description = "Nom de la base de données MySQL"
  type        = string
  default     = "app_database"
}

variable "mysql_sku_name" {
  description = "SKU du serveur MySQL Flexible"
  type        = string
  default     = "B_Standard_B1ms"
  
  validation {
    condition = can(regex("^(B_Standard_B[0-9]+ms|GP_Standard_D[0-9]+s|MO_Standard_E[0-9]+s)$", var.mysql_sku_name))
    error_message = "Le SKU MySQL doit suivre le format Azure (ex: B_Standard_B1ms)."
  }
}

variable "mysql_version" {
  description = "Version de MySQL"
  type        = string
  default     = "8.0.21"
}

variable "mysql_storage_gb" {
  description = "Taille du stockage MySQL en GB"
  type        = number
  default     = 20
  
  validation {
    condition     = var.mysql_storage_gb >= 20 && var.mysql_storage_gb <= 16384
    error_message = "Le stockage MySQL doit être entre 20 et 16384 GB."
  }
}

variable "mysql_backup_retention_days" {
  description = "Nombre de jours de rétention des sauvegardes MySQL"
  type        = number
  default     = 7
  
  validation {
    condition     = var.mysql_backup_retention_days >= 1 && var.mysql_backup_retention_days <= 35
    error_message = "La rétention des sauvegardes doit être entre 1 et 35 jours."
  }
}

# Variables App Service
variable "app_service_sku" {
  description = "SKU du plan App Service"
  type        = string
  default     = "B1"
  
  validation {
    condition = can(regex("^(F1|D1|B[1-3]|S[1-3]|P[1-3]V[2-3]|I[1-3]V[2]|WS[1-3])$", var.app_service_sku))
    error_message = "SKU App Service invalide. Utilisez F1, D1, B1-B3, S1-S3, etc."
  }
}

variable "app_service_always_on" {
  description = "Maintenir l'App Service toujours actif"
  type        = bool
  default     = true
}

variable "create_staging_slot" {
  description = "Créer un slot de staging"
  type        = bool
  default     = false
}

# Variables Docker
variable "docker_image_name" {
  description = "Nom de l'image Docker"
  type        = string
  default     = "sample-app"
}

variable "docker_image_tag" {
  description = "Tag de l'image Docker"
  type        = string
  default     = "latest"
}

# Variables Laravel
variable "laravel_app_env" {
  description = "Environnement Laravel"
  type        = string
  default     = "production"
  
  validation {
    condition     = contains(["local", "development", "staging", "production"], var.laravel_app_env)
    error_message = "L'environnement Laravel doit être local, development, staging ou production."
  }
}

variable "laravel_app_debug" {
  description = "Mode debug Laravel"
  type        = string
  default     = "false"
  
  validation {
    condition     = contains(["true", "false"], var.laravel_app_debug)
    error_message = "Le mode debug doit être true ou false."
  }
}

variable "laravel_app_key" {
  description = "Clé d'application Laravel (base64)"
  type        = string
  default     = "base64:your-generated-app-key-here"
  sensitive   = true
}

# Variables de sécurité réseau (optionnelles)
variable "allowed_ip_ranges" {
  description = "Plages IP autorisées pour MySQL (optionnel)"
  type        = list(object({
    name             = string
    start_ip_address = string
    end_ip_address   = string
  }))
  default = []
}

# Variables de monitoring (optionnelles)
variable "enable_application_insights" {
  description = "Activer Application Insights"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "Nombre de jours de rétention des logs"
  type        = number
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 1 && var.log_retention_days <= 730
    error_message = "La rétention des logs doit être entre 1 et 730 jours."
  }
}

# ACR Fixed Credentials
variable "acr_admin_username" {
  description = "Fixed admin username for Azure Container Registry"
  type        = string
  default     = "acrstg10tf"
}

variable "acr_admin_password" {
  description = "Fixed admin password for Azure Container Registry"
  type        = string
  default     = "MyFixedACRPassword2024!"
  sensitive   = true
}

