# 🌍 Déploiement Multi-Environnement avec Tags

## 🎯 **Vue d'ensemble**

Ce système permet de déployer automatiquement l'application Laravel sur différents environnements Azure en utilisant des **tags Git** pour déclencher les déploiements.

## 🏷️ **Système de Tags**

### **Format des tags :**
```
{environnement}-v{version}
```

### **Environnements supportés :**

| Tag | Environnement | Description |
|-----|---------------|-------------|
| `dev-v1.0.0` | **Développement** | Tests et développement |
| `staging-v1.0.0` | **Staging** | Tests d'intégration |
| `prod-v1.0.0` | **Production** | Environnement live |

## 🚀 **Comment déployer**

### **1️⃣ Déploiement automatique par tag**

```bash
# Développement
git tag dev-v1.0.0
git push origin dev-v1.0.0

# Staging
git tag staging-v1.0.0  
git push origin staging-v1.0.0

# Production
git tag prod-v1.0.0
git push origin prod-v1.0.0
```

### **2️⃣ Déploiement manuel via GitHub UI**

1. **GitHub** → **Actions** → **"Multi-Environment Deployment"**
2. **"Run workflow"** → Choisir :
   - **Environment** : `dev` / `staging` / `prod`
   - **Action** : `deploy` / `destroy` / `plan`
3. **"Run workflow"**

## 🏗️ **Infrastructure par environnement**

### **🟢 Développement (dev)**
```
Resource Group : rg-dev-stg10
ACR           : acrdevstg10.azurecr.io
App Service   : app-dev-stg10.azurewebsites.net
MySQL         : mysql-dev-stg10.mysql.database.azure.com
```

### **🟡 Staging**
```
Resource Group : rg-staging-stg10
ACR           : acrstagingstg10.azurecr.io
App Service   : app-staging-stg10.azurewebsites.net
MySQL         : mysql-staging-stg10.mysql.database.azure.com
```

### **🔴 Production**
```
Resource Group : rg-prod-stg10
ACR           : acrprodstg10.azurecr.io
App Service   : app-prod-stg10.azurewebsites.net
MySQL         : mysql-prod-stg10.mysql.database.azure.com
```

## 🔄 **Workflow de déploiement**

### **Phase 1 : Détection d'environnement**
- Analyse du tag Git ou input manuel
- Configuration des variables d'environnement
- Sélection du workspace Terraform

### **Phase 2 : Plan Terraform** (si demandé)
- Génération du plan Terraform
- Affichage des changements prévus
- Sauvegarde du plan en artifact

### **Phase 3 : Déploiement ACR**
- Déploiement ciblé de l'Azure Container Registry
- Récupération des credentials ACR

### **Phase 4 : Build & Push Docker**
- Build de l'image Docker avec le code actuel
- Tag avec l'environnement : `{env}-{timestamp}` et `{env}-latest`
- Push vers l'ACR de l'environnement

### **Phase 5 : Infrastructure complète**
- Déploiement de toutes les ressources Azure
- MySQL Flexible Server, App Service, etc.

### **Phase 6 : Configuration MySQL**
- Création de l'utilisateur applicatif
- Attribution des permissions
- Configuration SSL

### **Phase 7 : Configuration App Service**
- Variables d'environnement spécifiques
- Configuration du conteneur Docker
- Redémarrage de l'application

### **Phase 8 : Vérification**
- Test de connectivité de l'application
- Validation du déploiement
- Rapport final

## 🎮 **Actions disponibles**

### **📋 `plan`** - Planification
```bash
# Via GitHub UI seulement
Actions → Multi-Environment Deployment → plan
```
- **Durée** : ~2 minutes
- **Résultat** : Affiche les changements Terraform prévus
- **Sécurisé** : Aucune modification réelle

### **🚀 `deploy`** - Déploiement
```bash
# Automatique par tag
git tag dev-v1.1.0 && git push origin dev-v1.1.0

# Ou manuel via GitHub UI
Actions → Multi-Environment Deployment → deploy
```
- **Durée** : ~15-20 minutes
- **Résultat** : Infrastructure complète déployée
- **Inclut** : Build Docker + Configuration complète

### **🗑️ `destroy`** - Suppression
```bash
# Via GitHub UI seulement (sécurité)
Actions → Multi-Environment Deployment → destroy
```
- **Durée** : ~5-10 minutes
- **Résultat** : Suppression complète de l'infrastructure
- **⚠️ ATTENTION** : Perte de données irréversible !

## 🔒 **Sécurité et contrôles**

### **GitHub Environments**
Chaque environnement peut avoir :
- **Reviewers requis** pour les déploiements
- **Délais d'attente** avant déploiement
- **Branches protégées** pour la production

### **Workspaces Terraform**
- **Isolation complète** entre environnements
- **States séparés** par environnement
- **Variables spécifiques** par workspace

### **Credentials Azure**
- **Service Principal unique** avec accès multi-environnement
- **Secrets centralisés** dans GitHub
- **Authentification sécurisée** pour Terraform

## 📊 **Monitoring et logs**

### **GitHub Actions**
- **Logs détaillés** pour chaque phase
- **Artifacts** des plans Terraform
- **Historique complet** des déploiements

### **Azure Monitor**
- **Application Insights** (optionnel)
- **Logs App Service** centralisés
- **Métriques MySQL** disponibles

## 🛠️ **Gestion des versions**

### **Stratégie de tags recommandée :**

```bash
# Développement - versions fréquentes
dev-v1.0.0, dev-v1.0.1, dev-v1.1.0

# Staging - versions stables
staging-v1.0.0, staging-v1.1.0

# Production - versions validées
prod-v1.0.0, prod-v1.1.0
```

### **Workflow recommandé :**

1. **Développement** → `dev-v1.x.x`
2. **Tests réussis** → `staging-v1.x.x`
3. **Validation complète** → `prod-v1.x.x`

## 🔧 **Configuration avancée**

### **Variables d'environnement Laravel**

| Variable | Dev | Staging | Prod |
|----------|-----|---------|------|
| `APP_ENV` | `dev` | `staging` | `production` |
| `APP_DEBUG` | `true` | `false` | `false` |
| `LOG_LEVEL` | `debug` | `info` | `warning` |

### **Ressources Azure par environnement**

| Ressource | Dev | Staging | Prod |
|-----------|-----|---------|------|
| **App Service SKU** | `B1` | `S1` | `P1V2` |
| **MySQL SKU** | `B_Standard_B1ms` | `GP_Standard_D2s` | `GP_Standard_D4s` |
| **ACR SKU** | `Basic` | `Standard` | `Premium` |

## 🚨 **Dépannage**

### **Erreurs communes :**

#### **Tag non reconnu**
```
❌ Tag format not recognized: feature-v1.0.0
✅ Utiliser : dev-v1.0.0, staging-v1.0.0, ou prod-v1.0.0
```

#### **Workspace Terraform manquant**
```
❌ Workspace 'dev' does not exist
✅ Le workflow crée automatiquement le workspace
```

#### **Ressources déjà existantes**
```
❌ Resource already exists
✅ Terraform gère automatiquement l'état existant
```

## 📞 **Support**

### **Logs GitHub Actions :**
- GitHub → Actions → Workflow run → Logs détaillés

### **Logs Azure :**
- App Service → Monitoring → Log stream
- MySQL → Monitoring → Logs

### **État Terraform :**
- Stocké dans Azure Storage Account
- Workspace séparés par environnement

---

## 🎉 **Résumé**

**Le système multi-environnement offre :**

✅ **Déploiements automatisés** par tags Git  
✅ **Isolation complète** entre environnements  
✅ **Sécurité renforcée** avec contrôles d'accès  
✅ **Traçabilité complète** des déploiements  
✅ **Rollback facile** en cas de problème  
✅ **Scalabilité** pour ajouter de nouveaux environnements  

**Un système DevOps moderne et robuste pour l'équipe STG-10 !** 🚀
