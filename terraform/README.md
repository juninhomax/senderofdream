# Infrastructure Terraform pour Application Laravel Azure

Ce dossier contient l'infrastructure complète Terraform pour déployer automatiquement l'application Laravel sur Azure avec toutes les ressources nécessaires.

## 🏗️ Architecture déployée

- **Azure Container Registry** : Stockage des images Docker
- **Azure Database for MySQL Flexible Server** : Base de données avec SSL obligatoire
- **Azure App Service Linux** : Hébergement de l'application conteneurisée
- **Configuration SSL** : Certificat DigiCert automatique
- **Variables d'environnement** : Configuration complète Laravel

## 📁 Structure des fichiers

```
terraform/
├── main.tf                    # Configuration principale des ressources
├── variables.tf               # Définition des variables
├── outputs.tf                 # Sorties du déploiement
├── terraform.tfvars.example   # Exemple de configuration
├── deploy.sh                  # Script de déploiement Linux/Mac
├── deploy.ps1                 # Script de déploiement Windows
└── README.md                  # Cette documentation
```

## 🚀 Déploiement rapide

### 1. Prérequis

- [Terraform](https://terraform.io) >= 1.0
- [Azure CLI](https://docs.microsoft.com/cli/azure/) connecté (`az login`)
- [Docker](https://docker.com) pour construire l'image
- Accès à un abonnement Azure avec droits de création de ressources

### 2. Configuration

```bash
# Copier le fichier d'exemple
cp terraform.tfvars.example terraform.tfvars

# Éditer les variables selon vos besoins
nano terraform.tfvars
```

**Variables importantes à configurer :**
```hcl
project_name = "votre-projet"
environment  = "prod"
location     = "France Central"

# Générer une clé Laravel
laravel_app_key = "base64:your-generated-key"
```

### 3. Déploiement automatique

**Linux/Mac :**
```bash
chmod +x deploy.sh
./deploy.sh
```

**Windows PowerShell :**
```powershell
.\deploy.ps1
```

### 4. Commandes manuelles

```bash
# Initialisation
terraform init

# Planification
terraform plan

# Déploiement
terraform apply

# Destruction
terraform destroy
```

## 🔧 Commandes utiles

### Déploiement par étapes

```bash
# Planification uniquement
./deploy.sh plan

# Application uniquement
./deploy.sh apply

# Construction Docker uniquement
./deploy.sh docker

# Informations de déploiement
./deploy.sh info

# Destruction complète
./deploy.sh destroy
```

### Gestion post-déploiement

```bash
# Voir les logs de l'application
az webapp log tail --name [app-name] --resource-group [rg-name]

# Redémarrer l'application
az webapp restart --name [app-name] --resource-group [rg-name]

# Se connecter à MySQL
mysql -h [mysql-host] -u app_user -p

# Mettre à l'échelle l'App Service
az appservice plan update --name [plan-name] --resource-group [rg-name] --sku B2
```

## 📊 Outputs disponibles

Après déploiement, Terraform fournit :

- **URL de l'application** : Accès direct à votre app
- **Informations ACR** : Pour pusher de nouvelles images
- **Connexion MySQL** : Paramètres de base de données
- **Commandes utiles** : Scripts de gestion

```bash
# Voir tous les outputs
terraform output

# Output spécifique
terraform output app_service_url
```

## 🔒 Sécurité

### Mots de passe générés automatiquement

- **MySQL Admin** : Généré aléatoirement (16 caractères)
- **MySQL App User** : Généré aléatoirement (16 caractères)
- **ACR** : Clés d'accès Azure automatiques

### Configuration SSL

- **MySQL** : SSL obligatoire avec certificat DigiCert
- **App Service** : HTTPS forcé
- **Variables sensibles** : Marquées comme `sensitive` dans Terraform

## 🎯 Personnalisation

### Variables principales

| Variable | Description | Défaut |
|----------|-------------|---------|
| `project_name` | Nom du projet | `sampleappstg10max` |
| `environment` | Environnement | `prod` |
| `location` | Région Azure | `France Central` |
| `app_service_sku` | Taille App Service | `B1` |
| `mysql_sku_name` | Taille MySQL | `B_Standard_B1ms` |

### Environnements multiples

```bash
# Développement
terraform workspace new dev
terraform apply -var="environment=dev" -var="app_service_sku=F1"

# Production
terraform workspace new prod
terraform apply -var="environment=prod" -var="app_service_sku=B2"
```

## 🐛 Résolution de problèmes

### Erreurs communes

1. **Nom de ressource déjà pris**
   ```bash
   # Changer le project_name dans terraform.tfvars
   project_name = "monprojet-unique-123"
   ```

2. **Quota Azure dépassé**
   ```bash
   # Vérifier les quotas
   az vm list-usage --location "France Central"
   ```

3. **Erreur de connexion MySQL**
   ```bash
   # Vérifier les règles de pare-feu
   az mysql flexible-server firewall-rule list --name [mysql-name] --resource-group [rg-name]
   ```

### Logs de débogage

```bash
# Logs Terraform détaillés
export TF_LOG=DEBUG
terraform apply

# Logs Azure CLI
az webapp log tail --name [app-name] --resource-group [rg-name]
```

## 🔄 Mise à jour de l'application

### Nouvelle version Docker

```bash
# 1. Modifier le code source
# 2. Rebuilder et pusher
./deploy.sh docker

# 3. Redémarrer l'App Service
az webapp restart --name [app-name] --resource-group [rg-name]
```

### Mise à jour infrastructure

```bash
# 1. Modifier main.tf ou variables
# 2. Planifier les changements
terraform plan

# 3. Appliquer les changements
terraform apply
```

## 💰 Coûts estimés

| Ressource | SKU | Coût mensuel (€) |
|-----------|-----|------------------|
| App Service | B1 | ~15 |
| MySQL Flexible | B1ms | ~25 |
| Container Registry | Standard | ~5 |
| **Total** | | **~45** |

## 📚 Documentation complémentaire

- [Documentation Terraform Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure App Service](https://docs.microsoft.com/azure/app-service/)
- [Azure Database for MySQL](https://docs.microsoft.com/azure/mysql/)
- [Azure Container Registry](https://docs.microsoft.com/azure/container-registry/)

## 🤝 Support

En cas de problème :

1. Vérifiez les logs Terraform : `terraform show`
2. Consultez les logs Azure : `az webapp log tail`
3. Vérifiez la documentation Azure officielle
4. Utilisez `terraform plan` pour voir les changements prévus

---

*Infrastructure as Code générée automatiquement*  
*Compatible avec Terraform >= 1.0 et Azure Provider >= 3.0*
