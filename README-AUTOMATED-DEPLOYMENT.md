# Déploiement Automatisé Laravel sur Azure

Ce guide explique comment déployer automatiquement une application Laravel sur Azure en utilisant **Terraform + Ansible** pour une automatisation complète.

## 🚀 Déploiement en Une Commande

### Linux/macOS
```bash
cd terraform
./deploy.sh
```

### Windows
```powershell
cd terraform
.\deploy-automated.ps1
```

## 📋 Prérequis

### Outils requis
- **Terraform** >= 1.0
- **Azure CLI** >= 2.0
- **Ansible** >= 4.0
- **Docker** (pour build local)
- **Python** avec pip (pour Ansible)

### Installation rapide des prérequis

#### Windows
```powershell
# Installer Chocolatey si pas déjà fait
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Installer les outils
choco install terraform azure-cli docker-desktop python3
pip install ansible

# Installer les collections Ansible
ansible-galaxy install -r terraform/ansible/requirements.yml
```

#### Linux/macOS
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install terraform azure-cli docker.io python3-pip
pip3 install ansible

# macOS avec Homebrew
brew install terraform azure-cli docker python3
pip3 install ansible

# Installer les collections Ansible
ansible-galaxy install -r terraform/ansible/requirements.yml
```

## 🔧 Configuration

### 1. Connexion Azure
```bash
az login
az account set --subscription "votre-subscription-id"
```

### 2. Configuration Terraform (optionnel)
Créez `terraform/terraform.tfvars` si vous voulez personnaliser :
```hcl
project_name = "mon-projet"
environment = "prod"
location = "France Central"
```

## 🎯 Déploiement Automatisé

### Déploiement complet
```bash
# Linux/macOS
cd terraform
./deploy.sh

# Windows
cd terraform
.\deploy-automated.ps1
```

### Options avancées

#### Planification seulement
```bash
# Linux/macOS
./deploy.sh plan

# Windows
.\deploy-automated.ps1 -PlanOnly
```

#### Déploiement sans confirmation
```bash
# Linux/macOS
./deploy.sh apply

# Windows  
.\deploy-automated.ps1 -AutoApprove
```

#### Destruction de l'infrastructure
```bash
# Linux/macOS
./deploy.sh destroy

# Windows
.\deploy-automated.ps1 -Destroy
```

## 🔄 Processus d'Automatisation

Le déploiement automatisé exécute les étapes suivantes :

### 1. **Terraform** - Infrastructure
- Création du Resource Group
- Déploiement Azure Container Registry
- Configuration MySQL Flexible Server
- Création App Service Linux
- Configuration réseau et sécurité

### 2. **Ansible** - Application (automatique)
- Build de l'image Docker Laravel
- Push vers Azure Container Registry
- Configuration des variables d'environnement
- Configuration du conteneur App Service
- Redémarrage et vérification

## 📊 Ressources Créées

| Ressource | Nom | Description |
|-----------|-----|-------------|
| Resource Group | `rg-{project}-{env}` | Groupe de ressources principal |
| Container Registry | `acr{project}{env}tf` | Registry Docker privé |
| MySQL Server | `mysql-{project}-{env}-tf` | Base de données MySQL |
| App Service | `app-{project}-{env}-tf` | Service web Laravel |
| App Service Plan | `plan-{project}-{env}-tf` | Plan d'hébergement |

## 🔍 Vérification du Déploiement

### Vérifier l'état des ressources
```bash
cd terraform
terraform output
```

### Tester l'application
```bash
# Récupérer l'URL
APP_URL=$(cd terraform && terraform output -raw app_service_url)
curl -I $APP_URL
```

### Consulter les logs
```bash
# Logs en temps réel
az webapp log tail --name $(cd terraform && terraform output -raw app_service_name) --resource-group $(cd terraform && terraform output -raw resource_group_name)

# Logs du conteneur
az webapp log download --name $(cd terraform && terraform output -raw app_service_name) --resource-group $(cd terraform && terraform output -raw resource_group_name)
```

## 🛠️ Dépannage

### Problèmes courants

#### 1. Erreur d'authentification Azure
```bash
az login
az account show  # Vérifier la subscription active
```

#### 2. Erreur Ansible "collection not found"
```bash
ansible-galaxy install -r terraform/ansible/requirements.yml --force
```

#### 3. Erreur Docker "permission denied"
```bash
# Linux
sudo usermod -aG docker $USER
newgrp docker

# Windows - Redémarrer Docker Desktop
```

#### 4. Erreur 500 sur l'application
```bash
# Activer le debug temporairement
az webapp config appsettings set --name APP_NAME --resource-group RG_NAME --settings APP_DEBUG="true"

# Consulter les logs détaillés
az webapp log tail --name APP_NAME --resource-group RG_NAME
```

### Logs et monitoring

#### Logs Terraform
```bash
export TF_LOG=INFO
terraform apply
```

#### Logs Ansible
```bash
ansible-playbook -vvv terraform/ansible/deploy-app.yml
```

#### Logs Azure App Service
```bash
# Via Azure CLI
az webapp log tail --name APP_NAME --resource-group RG_NAME

# Via le portail Azure
https://portal.azure.com > App Services > Votre App > Logs
```

## 🔄 Mise à Jour de l'Application

### Redéploiement complet
```bash
cd terraform
./deploy.sh
```

### Mise à jour de l'image Docker seulement
```bash
# Via Ansible directement
cd terraform
ansible-playbook -i ansible/inventory.ini ansible/deploy-app.yml --tags docker
```

## 📈 Optimisations

### Performance
- L'image Docker est mise en cache pour accélérer les builds
- Les ressources Azure sont créées en parallèle
- Les variables d'environnement sont configurées via API REST (plus rapide)

### Sécurité
- Mots de passe générés automatiquement par Terraform
- SSL obligatoire pour MySQL
- Variables sensibles stockées dans Azure Key Vault (optionnel)
- Container Registry privé avec authentification

### Coûts
- App Service Plan B1 (Basic) par défaut
- MySQL Flexible Server B1ms par défaut
- Possibilité de passer en mode gratuit pour les tests

## 🎛️ Configuration Avancée

### Variables Terraform personnalisées
Créez `terraform/terraform.tfvars` :
```hcl
# Personnalisation du projet
project_name = "monapp"
environment = "prod"
location = "France Central"

# Taille des ressources
app_service_sku = "B2"  # Plus de puissance
mysql_sku = "B2s"       # Plus de performance DB

# Configuration réseau
allowed_ips = ["1.2.3.4", "5.6.7.8"]  # IPs autorisées pour MySQL
```

### Variables Ansible personnalisées
Modifiez `terraform/ansible/deploy-app.yml` :
```yaml
vars:
  # Configuration Docker
  docker_build_args:
    - "--no-cache"
    - "--compress"
  
  # Configuration Laravel
  app_debug: false
  app_env: production
  
  # Timeout personnalisés
  app_startup_timeout: 300
```

## 📚 Architecture

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Terraform     │───▶│     Ansible      │───▶│  Azure App      │
│  Infrastructure │    │   Application    │    │    Service      │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│ Azure Container │    │   Docker Build   │    │ Laravel App     │
│    Registry     │    │   & Push         │    │   Running       │
└─────────────────┘    └──────────────────┘    └─────────────────┘
```

## 🤝 Support

Pour obtenir de l'aide :
1. Consultez les logs détaillés
2. Vérifiez la documentation Azure
3. Testez les composants individuellement
4. Utilisez les commandes de diagnostic intégrées

---

**🎉 Votre application Laravel est maintenant déployée automatiquement sur Azure !**
