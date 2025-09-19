# Guide de déploiement Terraform avec Azure Cloud Shell

## 🚀 Avantages d'Azure Cloud Shell
- ✅ Accès automatique aux deux subscriptions (Azure for Students + Sub T-CLO)
- ✅ Terraform pré-installé
- ✅ Stockage persistant dans Azure Files
- ✅ Accessible depuis n'importe quel PC/navigateur
- ✅ Authentification Azure automatique

## 📁 Étape 1: Copier les fichiers vers Cloud Shell

### Option A: Upload via l'interface web
1. Ouvrir [Azure Cloud Shell](https://shell.azure.com)
2. Cliquer sur l'icône "Upload/Download files" (📁)
3. Uploader tous les fichiers du dossier `terraform/`

### Option B: Cloner depuis Git (Recommandé)
```bash
# Dans Cloud Shell
cd ~
git clone <votre-repo-git> laravel-terraform
cd laravel-terraform/terraform
```

### Option C: Copier-coller les fichiers
Créer chaque fichier manuellement dans Cloud Shell avec `nano` ou `code`.

## 🔧 Étape 2: Configuration dans Cloud Shell

```bash
# Vérifier les subscriptions disponibles
az account list --output table

# Définir la subscription Sub T-CLO
az account set --subscription "6b9318b1-2215-418a-b0fd-ba0832e9b333"

# Vérifier la subscription active
az account show --query "{Name:name, SubscriptionId:id}" --output table

# Vérifier l'existence du groupe de ressources
az group show --name "rg-stg_10" --query "{Name:name, Location:location}" --output table
```

## 🏗️ Étape 3: Déploiement Terraform

```bash
# Naviguer vers le dossier terraform
cd ~/laravel-terraform/terraform

# Initialiser Terraform
terraform init

# Vérifier la configuration
terraform validate

# Planifier le déploiement
terraform plan

# Appliquer le déploiement
terraform apply
```

## 📋 Fichiers à copier vers Cloud Shell

### Fichiers principaux
- `main.tf` - Configuration infrastructure
- `variables.tf` - Variables Terraform  
- `outputs.tf` - Sorties du déploiement
- `terraform.tfvars` - Configuration spécifique

### Scripts de déploiement
- `deploy.sh` - Script automatique Linux
- `README.md` - Documentation complète

### Fichiers optionnels
- `terraform.tfvars.example` - Exemple de configuration
- `README_SUBSCRIPTION.md` - Guide des subscriptions

## 🔄 Workflow complet dans Cloud Shell

```bash
# 1. Configuration initiale
az account set --subscription "6b9318b1-2215-418a-b0fd-ba0832e9b333"
az group show --name "rg-stg_10"

# 2. Déploiement infrastructure
cd ~/laravel-terraform/terraform
terraform init
terraform plan
terraform apply -auto-approve

# 3. Construction et push Docker
cd ..
# Récupérer les infos ACR depuis Terraform
ACR_LOGIN_SERVER=$(cd terraform && terraform output -raw acr_login_server)
ACR_USERNAME=$(cd terraform && terraform output -raw acr_admin_username)
ACR_PASSWORD=$(cd terraform && terraform output -raw acr_admin_password)

# Login ACR
echo $ACR_PASSWORD | docker login $ACR_LOGIN_SERVER --username $ACR_USERNAME --password-stdin

# Build et push
docker build -t $ACR_LOGIN_SERVER/sample-app:latest .
docker push $ACR_LOGIN_SERVER/sample-app:latest

# 4. Redémarrer l'App Service
RESOURCE_GROUP=$(cd terraform && terraform output -raw resource_group_name)
APP_SERVICE_NAME=$(cd terraform && terraform output -raw app_service_name)
az webapp restart --name $APP_SERVICE_NAME --resource-group $RESOURCE_GROUP

# 5. Voir les informations de déploiement
cd terraform
terraform output deployment_info
terraform output app_service_url
```

## 💾 Persistance des fichiers

Azure Cloud Shell utilise Azure Files pour le stockage persistant :
- **Emplacement**: `~/clouddrive/`
- **Capacité**: 5 GB inclus gratuitement
- **Accès**: Depuis n'importe quel navigateur/PC

```bash
# Déplacer vers le stockage persistant
mkdir -p ~/clouddrive/terraform-projects
cp -r ~/laravel-terraform ~/clouddrive/terraform-projects/
cd ~/clouddrive/terraform-projects/laravel-terraform/terraform
```

## 🎯 Commandes utiles Cloud Shell

```bash
# Vérifier l'espace disque
df -h

# Lister les fichiers Terraform
ls -la *.tf

# Voir l'état Terraform
terraform show

# Détruire l'infrastructure (si besoin)
terraform destroy

# Voir les logs d'une ressource
az webapp log tail --name <app-name> --resource-group <rg-name>
```

## 🔒 Sécurité et bonnes pratiques

- ✅ Les credentials Azure sont gérés automatiquement
- ✅ Pas besoin de stocker des clés API localement  
- ✅ Accès sécurisé via authentification Azure AD
- ✅ Isolation des environnements par subscription

## 🐛 Résolution de problèmes

### Erreur de subscription
```bash
az account set --subscription "6b9318b1-2215-418a-b0fd-ba0832e9b333"
az account show
```

### Erreur Terraform
```bash
terraform refresh
terraform plan
```

### Erreur Docker
```bash
# Vérifier Docker
docker --version
# Réinstaller si nécessaire
sudo apt-get update && sudo apt-get install docker.io
```

---

## 🎉 Résultat attendu

Après déploiement, vous aurez :
- Infrastructure complète dans `rg-stg_10`
- Application Laravel accessible via URL fournie
- Possibilité de gérer depuis n'importe quel PC
- Fichiers Terraform sauvegardés dans Azure Files

**URL d'accès**: Fournie par `terraform output app_service_url`
