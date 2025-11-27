# 🎓 Guide Setup Epitech - T-CLO-901

## 🚀 **Étapes Obligatoires pour Faire Fonctionner le Projet**

### **1️⃣ Configuration Azure Service Principal (CRITIQUE)**

#### **A. Créer le Service Principal**
```bash
# Se connecter à Azure
az login

# Vérifier l'abonnement actuel
az account show

# Créer le Service Principal (REMPLACER [SUBSCRIPTION-ID])
az ad sp create-for-rbac \
  --name "sp-epitech-stg10-github" \
  --role contributor \
  --scopes /subscriptions/[SUBSCRIPTION-ID] \
  --sdk-auth
```

#### **B. Copier le JSON résultant**
```json
{
  "clientId": "xxx-xxx-xxx",
  "clientSecret": "xxx-xxx-xxx", 
  "subscriptionId": "xxx-xxx-xxx",
  "tenantId": "xxx-xxx-xxx"
}
```

### **2️⃣ Configuration GitHub Secret**

#### **A. Aller dans le repo GitHub**
- https://github.com/EpitechMscProPromo2026/T-CLO-901-STG_10
- **Settings** → **Secrets and variables** → **Actions**

#### **B. Créer le secret**
- **New repository secret**
- **Name** : `AZURE_CREDENTIALS`
- **Secret** : Coller le JSON complet du Service Principal
- **Add secret**

### **3️⃣ Vérifier les Permissions Azure**

#### **A. Resource Group requis**
```bash
# Vérifier si le RG existe
az group show --name rg-stg_10

# Si il n'existe pas, le créer
az group create --name rg-stg_10 --location "France Central"
```

#### **B. Permissions du Service Principal**
```bash
# Vérifier les permissions (remplacer CLIENT-ID)
az role assignment list --assignee [CLIENT-ID] --output table
```

### **4️⃣ Premier Déploiement**

#### **A. Déployer l'environnement DEV**
```bash
git tag dev-v1.0.0
git push origin dev-v1.0.0
```

#### **B. Suivre le déploiement**
- GitHub → Actions → Voir le workflow "Multi-Environment Deployment"
- Durée attendue : 15-20 minutes

#### **C. Résultat attendu**
- **URL DEV** : https://app-dev-stg10.azurewebsites.net
- **Message** : "🔄 CONTINUOUS DEPLOYMENT TEST - No Restart v1.3 ⚡"

### **5️⃣ Test des Autres Environnements**

#### **A. Staging**
```bash
git tag staging-v1.0.0
git push origin staging-v1.0.0
# URL : https://app-staging-stg10.azurewebsites.net
```

#### **B. Production**
```bash
git tag prod-v1.0.0
git push origin prod-v1.0.0
# URL : https://app-prod-stg10.azurewebsites.net
```

## 🚨 **Dépannage Courant**

### **Erreur : "AZURE_CREDENTIALS not found"**
- Vérifier que le secret GitHub est bien créé
- Nom exact : `AZURE_CREDENTIALS` (sensible à la casse)

### **Erreur : "Permission denied"**
- Le Service Principal n'a pas les bonnes permissions
- Vérifier le rôle `contributor` sur la subscription

### **Erreur : "Resource group not found"**
- Créer le RG `rg-stg_10` manuellement
- Ou donner permission au SP de créer des RG

### **Erreur : "Terraform state lock"**
- Attendre que le déploiement précédent se termine
- Ou supprimer le lock manuellement dans Azure Storage

## 📊 **Validation du Projet**

### **✅ Checklist Epitech**
- [ ] **Multi-environnement** : 3 environnements fonctionnels
- [ ] **Zero Downtime** : Déploiement sans interruption
- [ ] **Infrastructure as Code** : Terraform complet
- [ ] **CI/CD** : GitHub Actions automatisé
- [ ] **Containerisation** : Docker + ACR
- [ ] **Sécurité** : SSL/TLS + Service Principal
- [ ] **Documentation** : Guides complets
- [ ] **Monitoring** : Logs centralisés

### **🎯 Démonstration Recommandée**
1. **Montrer le code** : Architecture Laravel + Docker
2. **Expliquer l'infrastructure** : Terraform + Azure
3. **Démontrer le déploiement** : Tag → Déploiement automatique
4. **Tester zero downtime** : Mise à jour sans interruption
5. **Montrer les environnements** : Dev/Staging/Prod isolés

## 🏆 **Points Forts du Projet**

### **🔧 Technique**
- **Terraform** : Infrastructure reproductible
- **GitHub Actions** : CI/CD moderne
- **Docker** : Containerisation complète
- **Azure** : Cloud computing professionnel

### **📚 DevOps**
- **Multi-environnement** : Isolation complète
- **Zero Downtime** : Déploiement sans interruption
- **Monitoring** : Observabilité complète
- **Sécurité** : Bonnes pratiques appliquées

### **🎓 Pédagogique**
- **Documentation** : Guides détaillés
- **Reproductibilité** : Setup en 5 minutes
- **Scalabilité** : Ajout d'environnements facile
- **Maintenance** : Code propre et organisé

---

## 📞 **Support**

En cas de problème :
1. **Vérifier les logs** GitHub Actions
2. **Consulter Azure Portal** pour les ressources
3. **Vérifier les permissions** du Service Principal

**Bon déploiement ! 🚀**
