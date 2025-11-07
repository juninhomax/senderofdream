# 🚀 Déploiement Full-Stack via GitHub Actions Runner

## 🎯 Nouvelle Architecture

### **Avant (deploy.sh)**
```
Local/Cloud Shell → deploy.sh → Terraform → GitHub Actions → Configuration manuelle
```

### **Maintenant (GitHub Actions)**
```
Git Push → GitHub Actions → Terraform → Docker Build → Configuration automatique
```

## 🔄 **Workflows disponibles**

### **1. Déploiement automatique (Push)**
```bash
# Push sur la branche déclenche automatiquement le déploiement complet
git push origin migrate-deploy-to-runner
```

### **2. Déploiement manuel**
- Aller sur GitHub Actions
- Sélectionner "Full Infrastructure & Application Deployment"
- Choisir "Run workflow"
- Sélectionner l'action : `deploy`, `destroy`, ou `plan`

### **3. Plan Terraform (Pull Request)**
```bash
# Créer une PR déclenche automatiquement un plan Terraform
git checkout -b feature/my-feature
git push origin feature/my-feature
# Créer PR vers migrate-deploy-to-runner
```

## 🏗️ **Phases de déploiement**

### **Phase 1 : ACR**
- Déploie Azure Container Registry
- Récupère les credentials

### **Phase 2 : Docker**
- Build l'image Laravel
- Push vers ACR

### **Phase 3 : Infrastructure**
- Déploie MySQL Flexible Server
- Déploie App Service
- Configure le réseau

### **Phase 4 : MySQL**
- Crée l'utilisateur `app_user`
- Configure les permissions
- Prépare la base de données

### **Phase 5 : App Service**
- Configure les variables d'environnement
- Configure le container Docker
- Redémarre l'application

### **Phase 6 : Vérification**
- Teste la connectivité
- Valide le déploiement

## 🎮 **Utilisation**

### **Déploiement complet**
```bash
# Option 1: Push automatique
git add .
git commit -m "Deploy new version"
git push origin migrate-deploy-to-runner

# Option 2: Manuel via GitHub UI
# GitHub → Actions → Full Infrastructure & Application Deployment → Run workflow → deploy
```

### **Destruction**
```bash
# Via GitHub UI seulement
# GitHub → Actions → Full Infrastructure & Application Deployment → Run workflow → destroy
```

### **Plan Terraform**
```bash
# Via GitHub UI
# GitHub → Actions → Full Infrastructure & Application Deployment → Run workflow → plan
```

## 🔧 **Variables d'environnement**

Le workflow utilise automatiquement :
- `AZURE_CREDENTIALS` (secret GitHub)
- Variables Terraform (générées automatiquement)
- Configuration ACR (récupérée dynamiquement)

## 📊 **Avantages**

### **✅ Automatisation complète**
- Plus besoin de Cloud Shell
- Plus de commandes manuelles
- Déploiement en 1 clic

### **✅ Traçabilité**
- Tous les logs dans GitHub Actions
- Historique des déploiements
- Rollback facile

### **✅ Sécurité**
- Credentials centralisés
- Pas d'exposition locale
- Audit trail complet

### **✅ Collaboration**
- Toute l'équipe peut déployer
- Pas de setup local requis
- Processus standardisé

## 🚨 **Points d'attention**

### **Permissions GitHub**
- Le repository doit avoir accès aux secrets `AZURE_CREDENTIALS`
- Les workflows doivent être activés

### **Ressources Azure**
- Le déploiement prend ~15-20 minutes
- Les ressources sont créées dans `rg-stg_10`
- Coûts Azure à surveiller

### **Conflits**
- Un seul déploiement à la fois
- Terraform state géré automatiquement
- Pas de conflits manuels

## 🔗 **URLs importantes**

- **Application** : https://app-stg10-tf.azurewebsites.net
- **GitHub Actions** : https://github.com/juninhomax/senderofdream/actions
- **Azure Portal** : https://portal.azure.com

## 📈 **Monitoring**

### **Logs Application**
```bash
az webapp log tail --name app-stg10-tf --resource-group rg-stg_10
```

### **Status Infrastructure**
```bash
az resource list --resource-group rg-stg_10 --output table
```

---

**🎉 Déploiement moderne et automatisé pour l'équipe STG-10 !**
