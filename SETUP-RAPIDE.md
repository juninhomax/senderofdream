# ⚡ Setup Rapide - 5 Minutes

## 🎯 **Objectif :** Déployer l'application en 5 minutes

### **📋 Prérequis (2 min)**
- [ ] Compte Azure (Azure for Students)
- [ ] Compte GitHub
- [ ] Azure CLI installé

### **🔧 Étape 1 : Service Principal Azure (1 min)**
```bash
# Remplacer [SUBSCRIPTION-ID] par votre ID
az ad sp create-for-rbac \
  --name "sp-ecole-github" \
  --role contributor \
  --scopes /subscriptions/[SUBSCRIPTION-ID] \
  --sdk-auth
```

**Copier le résultat JSON !**

### **🔧 Étape 2 : GitHub Setup (1 min)**
```bash
# 1. Créer un nouveau repo sur GitHub
# 2. Settings → Secrets and variables → Actions
# 3. New repository secret : AZURE_CREDENTIALS
# 4. Coller le JSON de l'étape 1
```

### **🔧 Étape 3 : Pousser le Code (1 min)**
```bash
git init
git add .
git commit -m "🚀 Initial commit"
git remote add origin https://github.com/[USERNAME]/[REPO].git
git push -u origin main
```

### **🚀 Étape 4 : Premier Déploiement (30 sec)**
```bash
git tag dev-v1.0.0
git push origin dev-v1.0.0
```

## ✅ **C'est tout !**

- ⏱️ **Temps total** : ~5 minutes
- 🔄 **GitHub Actions** : Se lance automatiquement
- ⏳ **Attendre** : 15-20 minutes pour le déploiement complet
- 🌐 **Résultat** : https://app-dev-[nom].azurewebsites.net

## 🎉 **Prochaines étapes**

```bash
# Modifier du code, puis :
git add .
git commit -m "Update code"
git push
git tag dev-v1.1.0
git push origin dev-v1.1.0
```

**Déploiement automatique sans downtime ! 🚀**
