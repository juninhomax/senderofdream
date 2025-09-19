# Laravel Azure Deployment - Sender of Dream

Application Laravel avec déploiement automatisé sur Azure utilisant Terraform et Docker.

## 🚀 Déploiement Automatisé Azure

Ce projet inclut un script de déploiement entièrement automatisé qui déploie l'infrastructure Azure et configure l'application Laravel.

### Prérequis

- Azure CLI installé et connecté (`az login`)
- Docker Desktop en cours d'exécution
- Terraform installé
- Git Bash ou terminal compatible

### Architecture Déployée

- **Azure Container Registry (ACR)** - Stockage des images Docker
- **Azure Database for MySQL** - Base de données flexible avec SSL
- **Azure App Service** - Hébergement de l'application Laravel
- **Azure Service Plan** - Plan d'hébergement Linux

### 🎯 Déploiement en Une Commande

```bash
cd terraform
./deploy.sh all
```

Cette commande unique :
1. ✅ Déploie toute l'infrastructure Azure avec Terraform
2. ✅ Construit et pousse l'image Docker vers ACR
3. ✅ Configure la base de données MySQL avec SSL
4. ✅ Crée l'utilisateur d'application MySQL
5. ✅ Configure toutes les variables d'environnement
6. ✅ Démarre l'application Laravel

### 📋 Commandes Disponibles

```bash
# Déploiement complet (infrastructure + application)
./deploy.sh all

# Déploiement infrastructure seulement
./deploy.sh

# Configuration application seulement (si infrastructure existe)
./deploy.sh configure

# Destruction complète de l'infrastructure
./deploy.sh destroy

# Afficher le plan Terraform
./deploy.sh plan

# Aide
./deploy.sh help
```

### 🔧 Configuration Automatique

Le script configure automatiquement :
- Variables d'environnement Laravel (APP_KEY, APP_ENV, etc.)
- Connexion MySQL sécurisée avec SSL
- Authentification ACR pour Docker
- Utilisateur MySQL dédié pour l'application
- Certificats SSL pour Azure MySQL

### 🌐 Accès à l'Application

Une fois déployée, l'application est accessible à :
`https://app-stg10-tf.azurewebsites.net`

### 🛠️ Développement Local

#### Configuration .env

Créer un fichier `.env` pour le développement local :

```conf
DB_CONNECTION=mysql
DB_HOST=xxx.xxx.xxx.xxx
DB_PORT=3306
DB_DATABASE=db_name
DB_USERNAME=username
DB_PASSWORD=passwd
```

#### Migrations et Seeders

```bash
# Création du schéma
php artisan migrate

# Seed du jeu de données
php artisan db:seed
```

### 📁 Structure du Projet

```
├── terraform/           # Configuration Infrastructure as Code
│   ├── deploy.sh        # Script de déploiement automatisé
│   ├── main.tf          # Configuration Terraform principale
│   ├── variables.tf     # Variables Terraform
│   └── outputs.tf       # Outputs Terraform
├── Dockerfile           # Configuration Docker
├── start.sh            # Script de démarrage du conteneur
└── app/                # Application Laravel
```

### 🔒 Sécurité

- Connexions MySQL chiffrées avec SSL/TLS
- Mots de passe générés automatiquement
- Variables sensibles protégées dans Terraform
- Authentification ACR sécurisée
- HTTPS obligatoire sur App Service

### 🚨 Dépannage

En cas de problème :

```bash
# Vérifier les logs de l'application
az webapp log tail --name app-stg10-tf --resource-group rg-stg_10

# Redémarrer l'application
az webapp restart --name app-stg10-tf --resource-group rg-stg_10

# Vérifier l'état des ressources
terraform show
```
