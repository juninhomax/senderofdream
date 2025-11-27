# 🚀 Application Laravel Multi-Environnement - Projet École

## 🎯 **Vue d'ensemble**

Application Laravel complète avec déploiement automatisé multi-environnement sur Azure, utilisant GitHub Actions et Terraform pour une infrastructure as code.

## 🌍 **Environnements Disponibles**

### **🟢 Développement**
- **URL** : https://app-dev-[votre-nom].azurewebsites.net
- **Déclencheur** : Tag `dev-v1.x.x`
- **Usage** : Tests et développement

### **🟡 Staging** 
- **URL** : https://app-staging-[votre-nom].azurewebsites.net
- **Déclencheur** : Tag `staging-v1.x.x`
- **Usage** : Tests d'intégration

### **🔴 Production**
- **URL** : https://app-prod-[votre-nom].azurewebsites.net
- **Déclencheur** : Tag `prod-v1.x.x`
- **Usage** : Environnement live

## 🚀 **Déploiement Ultra-Simple**

### **Déployer sur DEV :**
```bash
git tag dev-v1.0.0
git push origin dev-v1.0.0
```

### **Déployer sur STAGING :**
```bash
git tag staging-v1.0.0
git push origin staging-v1.0.0
```

### **Déployer sur PROD :**
```bash
git tag prod-v1.0.0
git push origin prod-v1.0.0
```

## ⚡ **Fonctionnalités Avancées**

- ✅ **Zero Downtime Deployment** : Mise à jour sans interruption
- ✅ **Infrastructure as Code** : Terraform pour Azure
- ✅ **Continuous Integration** : Tests automatiques
- ✅ **Multi-Environment** : Dev/Staging/Prod isolés
- ✅ **Docker Containerization** : Application containerisée
- ✅ **MySQL SSL** : Base de données sécurisée
- ✅ **Monitoring** : Logs centralisés Azure

## 🛠️ **Technologies Utilisées**

| Technologie | Usage |
|-------------|-------|
| **Laravel 8** | Framework PHP |
| **Docker** | Containerisation |
| **Azure App Service** | Hébergement |
| **Azure MySQL** | Base de données |
| **Azure Container Registry** | Registry Docker |
| **GitHub Actions** | CI/CD |
| **Terraform** | Infrastructure as Code |

## 📋 **Setup Initial (Une seule fois)**

### **1. Prérequis Azure**
- Compte Azure (Azure for Students OK)
- Service Principal avec permissions Contributor
- Resource Group créé

### **2. Configuration GitHub**
```bash
# 1. Créer le repo sur GitHub
# 2. Ajouter le secret AZURE_CREDENTIALS
# 3. Pousser le code
git init
git add .
git commit -m "🚀 Initial commit - Multi-environment Laravel app"
git remote add origin https://github.com/[votre-username]/[votre-repo].git
git push -u origin main
```

### **3. Premier Déploiement**
```bash
# Déployer l'environnement de dev
git tag dev-v1.0.0
git push origin dev-v1.0.0
```

## 🔧 **Configuration Azure (Détaillée)**

### **Service Principal :**
```bash
az ad sp create-for-rbac --name "sp-[votre-nom]-github" --role contributor --scopes /subscriptions/[subscription-id] --sdk-auth
```

### **GitHub Secret AZURE_CREDENTIALS :**
```json
{
  "clientId": "xxx",
  "clientSecret": "xxx", 
  "subscriptionId": "xxx",
  "tenantId": "xxx"
}
```

## 📊 **Workflow de Développement Recommandé**

1. **Développement local** → Commit & push
2. **Test sur DEV** → `git tag dev-v1.x.x`
3. **Validation STAGING** → `git tag staging-v1.x.x`  
4. **Release PROD** → `git tag prod-v1.x.x`

## 🔍 **Monitoring & Logs**

### **GitHub Actions :**
- Logs de déploiement complets
- Historique des déploiements
- Status en temps réel

### **Azure :**
- App Service Logs
- MySQL Metrics
- Application Insights (optionnel)

## 🚨 **Dépannage**

### **Erreurs communes :**

#### **Permissions Azure :**
```bash
# Vérifier les permissions du Service Principal
az role assignment list --assignee [client-id]
```

#### **MySQL Connection :**
```bash
# Vérifier la connectivité MySQL
az mysql flexible-server show --name mysql-dev-[nom] --resource-group rg-[nom]
```

#### **App Service Status :**
```bash
# Status de l'App Service
az webapp show --name app-dev-[nom] --resource-group rg-[nom] --query state
```

## 📚 **Documentation Complète**

- 📖 **[Guide Multi-Environnement](MULTI-ENVIRONMENT-DEPLOYMENT.md)** : Documentation détaillée
- 🔄 **[Comparaison Workflows](WORKFLOW-COMPARISON.md)** : Avantages de la solution
- ⚙️ **[Déploiement Automatisé](README-AUTOMATED-DEPLOYMENT.md)** : Guide technique

## 🎉 **Résultats Attendus**

Après setup complet, vous aurez :

- ✅ **3 environnements** fonctionnels sur Azure
- ✅ **Déploiement en 1 commande** (`git tag + git push`)
- ✅ **Zero downtime** sur les mises à jour
- ✅ **Infrastructure reproductible** avec Terraform
- ✅ **Monitoring complet** avec GitHub Actions + Azure

## 👨‍🎓 **Notes pour l'École**

Ce projet démontre :
- **DevOps moderne** avec CI/CD
- **Cloud Computing** sur Azure
- **Infrastructure as Code** 
- **Containerisation** Docker
- **Sécurité** SSL/TLS
- **Scalabilité** multi-environnement

**Un projet complet qui couvre tous les aspects du développement moderne !** 🚀

---

## 📞 **Support**

En cas de problème :
1. Vérifier les logs GitHub Actions
2. Consulter la documentation Azure
3. Vérifier les permissions du Service Principal

**Bon déploiement ! 🎯**
