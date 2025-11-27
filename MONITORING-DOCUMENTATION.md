# 📊 Documentation Monitoring - T-CLO-901

## 🎯 **Vue d'ensemble du système de monitoring**

Cette documentation présente l'architecture de monitoring mise en place pour le projet **T-CLO-901**, une application Laravel multi-environnement déployée sur Azure avec une approche DevOps complète.

---

## 🏗️ **Architecture de Monitoring**

### **📊 Stack de monitoring**
- **Azure Monitor** : Collecte des métriques infrastructure
- **Application Insights** : Monitoring applicatif (optionnel) => restriction Epitech
- **Azure Dashboard** : Visualisation centralisée
- **Locust** : Tests de charge et monitoring performance

### **🎯 Objectifs du monitoring**
1. **Surveillance proactive** des performances
2. **Détection précoce** des problèmes
3. **Optimisation** des ressources
4. **Validation** des déploiements
5. **Analyse** des tendances d'usage

---

## 🌐 **Composants surveillés**

### **1️⃣ Azure App Service (app-dev-stg10)**

#### **📈 Métriques de performance**
| Métrique | Description | Seuil Normal | Seuil Critique | Unité |
|----------|-------------|--------------|----------------|-------|
| **CPU Percentage** | Utilisation processeur | < 60% | > 80% | % |
| **Memory Working Set** | Mémoire physique utilisée | < 300MB | > 600MB | MB |
| **Average Response Time** | Temps de réponse moyen | < 2000ms | > 5000ms | ms |
| **Requests** | Nombre total de requêtes | Variable | - | Count |
| **Requests Per Second** | Débit de requêtes | 10-100 | > 200 | req/s |

#### **📊 Métriques de fiabilité**
| Métrique | Description | Seuil Normal | Seuil Critique | Action |
|----------|-------------|--------------|----------------|---------|
| **Http 2xx** | Requêtes réussies | > 95% | < 90% | Investigation |
| **Http 4xx** | Erreurs client | < 5% | > 10% | Vérification code |
| **Http 5xx** | Erreurs serveur | < 1% | > 5% | Redémarrage app |
| **Availability** | Disponibilité service | > 99% | < 95% | Escalade |

### **2️⃣ MySQL Flexible Server (mysql-dev-stg10)**

#### **📈 Métriques de performance**
| Métrique | Description | Seuil Normal | Seuil Critique | Unité |
|----------|-------------|--------------|----------------|-------|
| **cpu_percent** | Utilisation CPU DB | < 70% | > 85% | % |
| **memory_percent** | Utilisation mémoire DB | < 75% | > 90% | % |
| **io_percent** | Utilisation disque DB | < 80% | > 95% | % |
| **storage_percent** | Espace disque utilisé | < 80% | > 90% | % |

#### **🔗 Métriques de connectivité**
| Métrique | Description | Seuil Normal | Seuil Critique | Action |
|----------|-------------|--------------|----------------|---------|
| **active_connections** | Connexions actives | < 50 | > 100 | Pool tuning |
| **total_connections** | Connexions totales | Variable | > 500 | Investigation |
| **failed_connections** | Connexions échouées | < 5/min | > 20/min | Debug réseau |

---

## 📊 **Dashboard Azure personnalisé**

### **🎨 Layout du dashboard T-CLO-901**

```
┌─────────────────────┬─────────────────────┐
│  🌐 Web App Requests │  💻 Web App Resources│
│  • Total Requests   │  • CPU Percentage   │
│  • Requests/Sec     │  • Memory Working   │
│  • Response Time    │    Set              │
└─────────────────────┼─────────────────────┤
│  🗄️ MySQL Performance│  🔗 MySQL Connections│
│  • CPU Percent     │  • Active Conn.     │
│  • Memory Percent  │  • Total Conn.      │
│  • IO Percent      │  • Failed Conn.     │
├─────────────────────┴─────────────────────┤
│  📈 HTTP Status Distribution              │
│  • 2xx Success • 4xx Client • 5xx Server │
├───────────────────────────────────────────┤
│  🚨 Alerts & Notifications               │
│  • Active Alerts • Recent Events         │
└───────────────────────────────────────────┘
```

## 🚨 **Système d'alertes**

### **📧 Alertes critiques**

#### **App Service - Alertes haute priorité**
| Alerte | Condition | Durée | Action |
|--------|-----------|-------|--------|
| **High CPU** | CPU > 80% | 5 min | Email + SMS |
| **High Memory** | Memory > 600MB | 5 min | Email + SMS |
| **Slow Response** | Response Time > 5s | 2 min | Email |
| **High Error Rate** | 5xx > 5% | 1 min | Email + SMS |
| **Service Down** | Availability < 95% | 1 min | Email + SMS + Escalade |

#### **MySQL - Alertes haute priorité**
| Alerte | Condition | Durée | Action |
|--------|-----------|-------|--------|
| **DB High CPU** | CPU > 85% | 5 min | Email |
| **DB High Memory** | Memory > 90% | 5 min | Email |
| **Storage Full** | Storage > 90% | 1 min | Email + SMS |
| **Connection Issues** | Failed Conn > 20/min | 2 min | Email |

### **📱 Canaux de notification**
- **Email** : Alertes standard
- **SMS** : Alertes critiques uniquement
- **Teams/Slack** : Notifications équipe (optionnel)
- **Azure Mobile App** : Notifications push

---

## 🔍 **Tests de charge avec Locust**

### **🎯 Objectifs des tests**
1. **Validation** des performances sous charge
2. **Identification** des goulots d'étranglement
3. **Corrélation** avec les métriques Azure
4. **Optimisation** des ressources

### **📊 Scénarios de test**

#### **Test 1 - Charge légère (Baseline)**
```python
# Configuration Locust
users = 10
spawn_rate = 1
duration = "5m"
target_rps = 5-10
```
**Objectif** : Établir les métriques de référence

#### **Test 2 - Charge normale (Production)**
```python
# Configuration Locust  
users = 50
spawn_rate = 5
duration = "10m"
target_rps = 25-50
```
**Objectif** : Simuler la charge de production

#### **Test 3 - Pic de charge (Stress)**
```python
# Configuration Locust
users = 100
spawn_rate = 10  
duration = "5m"
target_rps = 75-100
```
**Objectif** : Tester les limites du système

### **📈 Métriques Locust vs Azure**

| Métrique Locust | Métrique Azure | Corrélation attendue |
|-----------------|----------------|---------------------|
| **RPS** | **RequestsPerSec** | Valeurs identiques |
| **Response Time** | **AverageResponseTime** | Tendances similaires |
| **Users** | **CpuPercentage** | Proportionnelle |
| **Failures** | **Http5xx** | Cohérence des erreurs |

### **🌐 Considérations réseau**

#### **Limitation réseau**
- **WiFi institutionnel** : Bridage à 1-5 req/s
- **Firewall** : Limitation des connexions simultanées

---

## 📋 **Procédures de monitoring**


#### **Métriques clés à surveiller**
1. **Disponibilité** : > 99%
2. **Temps de réponse** : < 2s
3. **Taux d'erreur** : < 1%
4. **Utilisation ressources** : < 70%
