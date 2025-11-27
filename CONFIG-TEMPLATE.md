# 🔧 Configuration Template pour Nouveau Repo

## ⚠️ **À MODIFIER avant le premier déploiement**

### **📋 Fichiers à personnaliser :**

#### **1. `.github/workflows/multi-env-deploy.yml` (lignes 72-87)**
```yaml
# REMPLACER "stg10" par votre identifiant unique
case $ENV in
  "dev")
    RG="rg-[VOTRE-NOM]"                    # Ex: rg-maxecole
    REGISTRY="acrdev[VOTRE-NOM].azurecr.io"    # Ex: acrdevmaxecole.azurecr.io
    APP_NAME="app-dev-[VOTRE-NOM]"             # Ex: app-dev-maxecole
    MYSQL_NAME="mysql-dev-[VOTRE-NOM]"         # Ex: mysql-dev-maxecole
    ;;
  "staging")
    RG="rg-[VOTRE-NOM]"
    REGISTRY="acrstaging[VOTRE-NOM].azurecr.io"
    APP_NAME="app-staging-[VOTRE-NOM]"
    MYSQL_NAME="mysql-staging-[VOTRE-NOM]"
    ;;
  "prod")
    RG="rg-[VOTRE-NOM]"
    REGISTRY="acrprod[VOTRE-NOM].azurecr.io"
    APP_NAME="app-prod-[VOTRE-NOM]"
    MYSQL_NAME="mysql-prod-[VOTRE-NOM]"
    ;;
esac
```

#### **2. `terraform/variables.tf` (lignes 30, 36, 42, 48)**
```hcl
variable "resource_group_name" {
  description = "Nom du groupe de ressources (défini par l'environnement)"
  type        = string
  default     = "rg-[VOTRE-NOM]"    # Ex: rg-maxecole
}

variable "acr_name" {
  description = "Nom de l'Azure Container Registry (défini par l'environnement)"
  type        = string
  default     = "acr[VOTRE-NOM]prod"    # Ex: acrmaxecoleprod
}

variable "app_service_name" {
  description = "Nom de l'App Service (défini par l'environnement)"
  type        = string
  default     = "app-[VOTRE-NOM]-tf"    # Ex: app-maxecole-tf
}

variable "mysql_server_name" {
  description = "Nom du serveur MySQL (défini par l'environnement)"
  type        = string
  default     = "mysql-[VOTRE-NOM]-tf"    # Ex: mysql-maxecole-tf
}
```

#### **3. `terraform/variables.tf` (ligne 61)**
```hcl
variable "azure_subscription_id" {
  description = "ID de la subscription Azure à utiliser"
  type        = string
  default     = "[VOTRE-SUBSCRIPTION-ID]"    # Remplacer par votre ID
}
```

## 🎯 **Exemple Complet pour "maxecole" :**

### **Workflow :**
- `RG="rg-maxecole"`
- `REGISTRY="acrdevmaxecole.azurecr.io"`
- `APP_NAME="app-dev-maxecole"`

### **URLs Finales :**
- **DEV** : https://app-dev-maxecole.azurewebsites.net
- **STAGING** : https://app-staging-maxecole.azurewebsites.net
- **PROD** : https://app-prod-maxecole.azurewebsites.net

## ✅ **Checklist avant déploiement :**

- [ ] Modifier les noms dans `multi-env-deploy.yml`
- [ ] Modifier les noms dans `terraform/variables.tf`
- [ ] Ajouter votre subscription ID Azure
- [ ] Configurer le secret `AZURE_CREDENTIALS` sur GitHub
- [ ] Créer le resource group sur Azure (ou donner permissions)

## 🚀 **Commandes de modification rapide :**

```bash
# Remplacer tous les "stg10" par votre nom
find . -name "*.yml" -o -name "*.tf" -o -name "*.md" | xargs sed -i 's/stg10/VOTRE-NOM/g'

# Remplacer la subscription ID
sed -i 's/6b9318b1-2215-418a-b0fd-ba0832e9b333/VOTRE-SUBSCRIPTION-ID/g' terraform/variables.tf
```

**Après modifications, suivre le SETUP-RAPIDE.md ! 🎯**
