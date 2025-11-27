# 📊 Guide de Monitoring - T-CLO-901

## 🎯 **Azure Monitor Dashboard pour T-CLO-901**

### **📈 Métriques App Service à surveiller**

#### **🌐 Performance Web**
- **Requests** : Nombre total de requêtes HTTP
- **Average Response Time** : Temps de réponse moyen
- **Http 2xx** : Requêtes réussies
- **Http 4xx** : Erreurs client (404, etc.)
- **Http 5xx** : Erreurs serveur (500, etc.)

#### **💻 Ressources Système**
- **CPU Percentage** : Utilisation processeur
- **Memory Percentage** : Utilisation mémoire
- **Data In/Out** : Trafic réseau
- **File System Usage** : Utilisation disque

### **🗄️ Métriques MySQL à surveiller**

#### **⚡ Performance Base**
- **CPU percent** : Charge processeur DB
- **Memory percent** : Utilisation mémoire DB
- **IO percent** : Utilisation disque DB
- **Storage percent** : Espace disque utilisé

#### **🔗 Connexions**
- **Active Connections** : Connexions actives
- **Failed Connections** : Connexions échouées
- **Connection Utilization** : Taux d'utilisation

### **🚨 Alertes recommandées**

#### **App Service - Seuils critiques**
- **CPU > 80%** pendant 5 minutes
- **Memory > 85%** pendant 5 minutes
- **Response Time > 3000ms** pendant 2 minutes
- **Error Rate > 5%** pendant 1 minute

#### **MySQL - Seuils critiques**
- **CPU > 75%** pendant 5 minutes
- **Memory > 80%** pendant 5 minutes
- **Storage > 85%** pendant 1 minute
- **Failed Connections > 10** pendant 1 minute

### **📊 Dashboard personnalisé**

#### **Étapes pour créer le dashboard :**

1. **Azure Portal** → **Dashboard** → **New dashboard**
2. **Nom** : `T-CLO-901 Monitoring`
3. **Ajouter des tuiles** :

**Tuile 1 - App Service Requests**
- Type : Metrics chart
- Resource : app-dev-stg10
- Metric : Requests
- Time range : Last 24 hours

**Tuile 2 - Response Time**
- Type : Metrics chart  
- Resource : app-dev-stg10
- Metric : Average Response Time
- Time range : Last 4 hours

**Tuile 3 - CPU Usage**
- Type : Metrics chart
- Resource : app-dev-stg10
- Metric : CPU Percentage
- Time range : Last 4 hours

**Tuile 4 - MySQL Performance**
- Type : Metrics chart
- Resource : mysql-dev-stg10
- Metric : CPU percent
- Time range : Last 4 hours

**Tuile 5 - Error Rate**
- Type : Metrics chart
- Resource : app-dev-stg10
- Metrics : Http 4xx, Http 5xx
- Time range : Last 4 hours

### **📝 Logs à surveiller**

#### **App Service Logs**
```bash
# Via Azure CLI
az webapp log tail --name app-dev-stg10 --resource-group rg-stg_10
```

#### **Types de logs importants :**
- **Application logs** : Erreurs Laravel
- **Web server logs** : Erreurs Apache
- **Failed request logs** : Requêtes échouées
- **Deployment logs** : Logs de déploiement

### **🔍 Requêtes KQL utiles**

#### **Erreurs les plus fréquentes**
```kql
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| where ScStatus >= 400
| summarize count() by ScStatus, CsUriStem
| order by count_ desc
```

#### **Pages les plus lentes**
```kql
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| where TimeTaken > 2000
| summarize avg(TimeTaken) by CsUriStem
| order by avg_TimeTaken desc
```

#### **Pics de trafic**
```kql
AppServiceHTTPLogs
| where TimeGenerated > ago(24h)
| summarize requests = count() by bin(TimeGenerated, 1h)
| order by TimeGenerated desc
```

### **📱 Monitoring en temps réel**

#### **Application Insights (si configuré)**
- **Live Metrics** : Métriques en temps réel
- **Performance** : Temps de réponse par endpoint
- **Failures** : Erreurs et exceptions
- **Users** : Utilisateurs actifs

#### **Azure Mobile App**
- Notifications push pour les alertes
- Consultation des métriques mobile
- Actions rapides de dépannage

### **🎯 Objectifs de performance**

#### **SLA Recommandés**
- **Disponibilité** : > 99.5%
- **Temps de réponse** : < 2 secondes
- **Taux d'erreur** : < 1%
- **CPU moyen** : < 60%

#### **Métriques de succès**
- **Throughput** : > 10 req/sec
- **Concurrent Users** : > 25
- **Database Response** : < 100ms
- **Memory Usage** : < 70%

### **🚨 Plan d'action en cas d'incident**

#### **CPU élevé (> 80%)**
1. Vérifier les requêtes lentes
2. Analyser les logs d'erreur
3. Considérer le scale-up
4. Optimiser le code si nécessaire

#### **Erreurs 5xx**
1. Consulter les logs applicatifs
2. Vérifier la connectivité DB
3. Redémarrer l'app si nécessaire
4. Analyser les derniers déploiements

#### **Base de données lente**
1. Vérifier les requêtes longues
2. Analyser l'utilisation des index
3. Considérer le scale-up MySQL
4. Optimiser les requêtes

---

## 🎉 **Conclusion**

Ce système de monitoring te permet de :
- ✅ **Surveiller** les performances en temps réel
- ✅ **Détecter** les problèmes avant les utilisateurs
- ✅ **Analyser** les tendances d'usage
- ✅ **Optimiser** les performances

**Un monitoring professionnel pour ton projet T-CLO-901 ! 📊🚀**
