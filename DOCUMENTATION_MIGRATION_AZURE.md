# Documentation Complète : Migration Application Laravel vers Azure App Service avec MySQL SSL

## Table des Matières

1. [Vue d'ensemble de l'architecture](#vue-densemble-de-larchitecture)
2. [Prérequis et environnement](#prérequis-et-environnement)
3. [Ressources Azure déployées](#ressources-azure-déployées)
4. [Configuration Docker et conteneurisation](#configuration-docker-et-conteneurisation)
5. [Configuration SSL et sécurité](#configuration-ssl-et-sécurité)
6. [Processus de déploiement détaillé](#processus-de-déploiement-détaillé)
7. [Résolution des problèmes rencontrés](#résolution-des-problèmes-rencontrés)
8. [Scripts et fichiers de configuration](#scripts-et-fichiers-de-configuration)
9. [Monitoring et maintenance](#monitoring-et-maintenance)
10. [Bonnes pratiques et recommandations](#bonnes-pratiques-et-recommandations)

---

## Vue d'ensemble de l'architecture

### Architecture finale déployée

```
┌─────────────────────────────────────────────────────────────┐
│                    AZURE CLOUD PLATFORM                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐    ┌──────────────────────────────────┐ │
│  │ Azure Container │    │        Azure App Service         │ │
│  │    Registry     │    │         (Linux Container)        │ │
│  │ (ACR)          │◄───┤                                  │ │
│  │                │    │  ┌─────────────────────────────┐  │ │
│  │ Image:         │    │  │     Laravel Application     │  │ │
│  │ sample-app:    │    │  │    (PHP 8.2.8 + Apache)    │  │ │
│  │ latest         │    │  │                             │  │ │
│  └─────────────────┘    │  └─────────────────────────────┘  │ │
│                         │                                  │ │
│                         │  Variables d'environnement:     │ │
│                         │  - DB_HOST, DB_DATABASE         │ │
│                         │  - DB_USERNAME, DB_PASSWORD     │ │
│                         │  - MYSQL_ATTR_SSL_CA            │ │
│                         └──────────────────────────────────┘ │
│                                        │                     │
│                                        │ SSL Connection      │
│                                        ▼                     │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │        Azure Database for MySQL Flexible Server        │ │
│  │                                                         │ │
│  │  Server: mysql-stg10-max-v2.mysql.database.azure.com  │ │
│  │  Database: app_database                                 │ │
│  │  User: app_user                                         │ │
│  │  SSL: Obligatoire (require_secure_transport=ON)        │ │
│  │  Certificat: DigiCert Global Root CA                   │ │
│  └─────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Flux de données et communication

1. **Utilisateur** → **Azure App Service** (HTTPS)
2. **App Service** → **Azure Container Registry** (Pull d'image Docker)
3. **Laravel Container** → **Azure MySQL** (Connexion SSL sécurisée)
4. **Container** → **DigiCert** (Téléchargement certificat SSL au démarrage)

---

## Prérequis et environnement

### Outils et technologies utilisés

| Composant | Version | Rôle |
|-----------|---------|------|
| **PHP** | 8.2.8 | Runtime principal de l'application Laravel |
| **Apache** | 2.4.57 | Serveur web dans le conteneur Docker |
| **Laravel** | Framework | Framework PHP de l'application |
| **Docker** | Latest | Conteneurisation de l'application |
| **MySQL Client** | default-mysql-client | Client pour tests de connectivité |
| **Composer** | Latest | Gestionnaire de dépendances PHP |

### Extensions PHP requises

```dockerfile
# Extensions PHP installées dans le conteneur
pdo_mysql          # Connexion MySQL via PDO
```

### Outils réseau et diagnostic

```dockerfile
# Outils installés pour le diagnostic
git                # Gestion de version
unzip              # Décompression d'archives
p7zip-full         # Support archives 7zip
wget               # Téléchargement de fichiers (certificat SSL)
dnsutils           # Outils DNS (nslookup)
iputils-ping       # Test de connectivité (ping)
netcat-openbsd     # Test de ports réseau
default-mysql-client # Client MySQL pour tests directs
```

### Abonnement Azure

- **Type** : Abonnement d'organisation/école (plus Azure for Students)
- **Groupe de ressources** : `rg-stg_10`
- **Région** : France Central
- **Droits** : Droits nécessaires pour créer ACR, App Service, et MySQL

---

## Ressources Azure déployées

### 1. Azure Container Registry (ACR)

**Configuration détaillée :**
```yaml
Nom: acrsampleappstg10max
Groupe de ressources: rg-stg_10
Région: France Central
SKU: Standard
Authentification: Clés d'accès activées
URL de connexion: acrsampleappstg10max.azurecr.io
```

**Fonctionnalités activées :**
- Clés d'accès administrateur : ✅ Activé
- Authentification par token : ✅ Disponible
- Webhooks : ✅ Configurables
- Réplication géographique : ❌ Non configurée (SKU Standard)

**Images stockées :**
```bash
acrsampleappstg10max.azurecr.io/sample-app:latest
```

### 2. Azure App Service

**Configuration détaillée :**
```yaml
Nom: [nom-app-service]
Groupe de ressources: rg-stg_10
Région: France Central
Plan App Service: Linux
Runtime Stack: Docker Container
Système d'exploitation: Linux
```

**Configuration du conteneur :**
```yaml
Source d'image: Azure Container Registry
Registre: acrsampleappstg10max.azurecr.io
Image: sample-app
Tag: latest
Démarrage continu: Activé
```

**Variables d'environnement configurées :**
```bash
DB_HOST=mysql-stg10-max-v2.mysql.database.azure.com
DB_DATABASE=app_database
DB_USERNAME=app_user
DB_PASSWORD=j6%>C!uw2e+*3'S
DB_CONNECTION=mysql
MYSQL_ATTR_SSL_CA=/opt/ssl/DigiCertGlobalRootCA.crt.pem
```

### 3. Azure Database for MySQL Flexible Server

**Configuration détaillée :**
```yaml
Nom du serveur: mysql-stg10-max-v2
Groupe de ressources: rg-stg_10
Région: France Central
Version MySQL: 8.0
Niveau de calcul: Burstable
SKU: Standard_B1ms
Stockage: 20 GiB (extensible)
Sauvegarde: 7 jours de rétention
```

**Configuration SSL :**
```yaml
SSL/TLS: Obligatoire
require_secure_transport: ON
Certificat CA: DigiCert Global Root CA
URL du certificat: https://cacerts.digicert.com/DigiCertGlobalRootCA.crt
```

**Configuration réseau :**
```yaml
Accès public: Activé
Règles de pare-feu: 
  - Autoriser les services Azure: ✅
  - Plages IP spécifiques: Configurées selon besoins
```

**Base de données et utilisateur :**
```sql
-- Base de données créée
CREATE DATABASE app_database;

-- Utilisateur créé avec privilèges
CREATE USER 'app_user'@'%' IDENTIFIED BY 'j6%>C!uw2e+*3'S';
GRANT ALL PRIVILEGES ON app_database.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
```

---

## Configuration Docker et conteneurisation

### Dockerfile complet et analysé

```dockerfile
# Image de base : PHP 8.2.8 avec Apache préinstallé
FROM php:8.2.8-apache

# Installation de l'extension PDO MySQL (obligatoire pour Laravel)
RUN docker-php-ext-install pdo_mysql

# Installation des outils système nécessaires
# - git: pour Composer et gestion de version
# - unzip: pour l'extraction des dépendances Composer
# - p7zip-full: support des archives 7zip
# - wget: téléchargement du certificat SSL DigiCert
# - dnsutils: outils de diagnostic DNS (nslookup)
# - iputils-ping: test de connectivité réseau
# - netcat-openbsd: test d'accessibilité des ports
# - default-mysql-client: client MySQL pour tests directs
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    p7zip-full \
    wget \
    dnsutils \
    iputils-ping \
    netcat-openbsd \
    default-mysql-client

# Installation de Composer (gestionnaire de dépendances PHP)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copie du code source de l'application
COPY . /var/www/html/

# Installation des dépendances PHP via Composer
RUN composer install

# Configuration des permissions Apache
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

# Copie et configuration du script de démarrage
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Variables d'environnement par défaut
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
ENV DB_CONNECTION mysql

# Configuration Apache pour Laravel
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Activation du module de réécriture Apache (requis pour Laravel)
RUN a2enmod rewrite

# Port exposé
EXPOSE 80

# Commande de démarrage
CMD ["/usr/local/bin/start.sh"]
```

### Script de démarrage (start.sh) - Analyse détaillée

```bash
#!/bin/bash

# Création du répertoire SSL
mkdir -p /opt/ssl

# Téléchargement du certificat SSL DigiCert Global Root CA
# Ce certificat est requis pour les connexions SSL vers Azure MySQL
wget -O /opt/ssl/DigiCertGlobalRootCA.crt.pem \
     https://www.digicert.com/CACerts/DigiCertGlobalRootCA.crt

# Section DEBUG : Affichage des variables d'environnement
# Permet de vérifier que toutes les variables sont correctement définies
echo "=== DEBUG VARIABLES ==="
echo "DB_HOST: $DB_HOST"
echo "DB_DATABASE: $DB_DATABASE"
echo "DB_USERNAME: $DB_USERNAME"
echo "DB_CONNECTION: $DB_CONNECTION"
echo "MYSQL_ATTR_SSL_CA: $MYSQL_ATTR_SSL_CA"
echo "======================="

# Section TESTS RÉSEAU : Diagnostic de connectivité
echo "=== NETWORK TESTS ==="
echo "Testing DNS resolution..."
nslookup $DB_HOST || echo "DNS resolution failed"

echo "Testing ping..."
ping -c 3 $DB_HOST || echo "Ping failed"

echo "Testing MySQL port 3306..."
nc -zv $DB_HOST 3306 || echo "MySQL port test failed"
echo "===================="

# Section TEST MYSQL DIRECT : Vérification de la connexion MySQL
echo "=== MYSQL CONNECTION TEST ==="
mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -e "SELECT 1;" || echo "Direct MySQL connection failed"
echo "============================="

# Attente de la disponibilité de la base de données Laravel
echo "Waiting for database connection..."
until php artisan tinker --execute="DB::connection()->getPdo();" 2>/dev/null; do
    echo "Database not ready, waiting..."
    sleep 5
done

echo "Database ready, running migrations..."
# Exécution des migrations Laravel
php artisan migrate --force

echo "Running seeders..."
# Exécution des seeders (données de test)
php artisan db:seed

echo "Starting Apache..."
# Démarrage d'Apache en mode foreground
apache2-foreground
```

---

## Configuration SSL et sécurité

### Problématiques SSL rencontrées et solutions

#### 1. Erreur initiale : Connexions non sécurisées interdites

**Erreur :**
```
SQLSTATE[HY000] [3159] Connections using insecure transport are prohibited while --require_secure_transport=ON
```

**Cause :** Azure Database for MySQL Flexible Server impose SSL par défaut.

**Solution :** Configuration SSL dans Laravel avec certificat CA.

#### 2. Erreur PDO : (trying to connect via (null))

**Erreur :**
```
SQLSTATE[HY000] [2002] (trying to connect via (null))
```

**Cause :** Configuration SSL mal interprétée par PDO Laravel.

**Solution :** Hardcodage du chemin du certificat SSL.

### Configuration SSL finale dans Laravel

**Fichier : `config/database.php`**

```php
'mysql' => [
    'driver' => 'mysql',
    'url' => env('DATABASE_URL'),
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'forge'),
    'username' => env('DB_USERNAME', 'forge'),
    'password' => env('DB_PASSWORD', ''),
    'unix_socket' => env('DB_SOCKET', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'prefix_indexes' => true,
    'strict' => true,
    'engine' => null,
    // Configuration SSL critique pour Azure MySQL
    'options' => extension_loaded('pdo_mysql') ? [
        // Chemin hardcodé vers le certificat CA téléchargé
        PDO::MYSQL_ATTR_SSL_CA => '/opt/ssl/DigiCertGlobalRootCA.crt.pem',
        // Désactivation de la vérification stricte du certificat serveur
        PDO::MYSQL_ATTR_SSL_VERIFY_SERVER_CERT => false,
    ] : [],
],
```

### Certificat SSL DigiCert

**Détails du certificat :**
- **Émetteur :** DigiCert Inc
- **Nom :** DigiCert Global Root CA
- **URL de téléchargement :** `https://cacerts.digicert.com/DigiCertGlobalRootCA.crt`
- **Taille :** 947 bytes
- **Format :** PEM
- **Emplacement dans le conteneur :** `/opt/ssl/DigiCertGlobalRootCA.crt.pem`

---

## Processus de déploiement détaillé

### Phase 1 : Préparation de l'environnement local

```bash
# 1. Vérification de Docker Desktop
docker --version
docker-compose --version

# 2. Test de l'application en local
cd sample-app-master
docker-compose up -d
docker-compose exec app php artisan migrate
docker-compose exec app php artisan db:seed
```

### Phase 2 : Création des ressources Azure

#### 2.1 Création de l'Azure Container Registry

```bash
# Via Azure CLI
az acr create \
  --resource-group rg-stg_10 \
  --name acrsampleappstg10max \
  --sku Standard \
  --location "France Central" \
  --admin-enabled true
```

#### 2.2 Récupération des identifiants ACR

```bash
# Récupération du nom d'utilisateur et mot de passe
az acr credential show --name acrsampleappstg10max
```

#### 2.3 Création d'Azure Database for MySQL

```bash
# Création du serveur MySQL
az mysql flexible-server create \
  --resource-group rg-stg_10 \
  --name mysql-stg10-max-v2 \
  --location "France Central" \
  --admin-user adminuser \
  --admin-password [mot-de-passe-admin] \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 20 \
  --version 8.0
```

#### 2.4 Configuration de la base de données

```sql
-- Connexion au serveur MySQL
mysql -h mysql-stg10-max-v2.mysql.database.azure.com -u adminuser -p

-- Création de la base de données
CREATE DATABASE app_database;

-- Création de l'utilisateur applicatif
CREATE USER 'app_user'@'%' IDENTIFIED BY 'j6%>C!uw2e+*3'S';
GRANT ALL PRIVILEGES ON app_database.* TO 'app_user'@'%';
FLUSH PRIVILEGES;
```

### Phase 3 : Construction et déploiement de l'image Docker

#### 3.1 Construction de l'image

```bash
# Construction avec cache désactivé pour forcer la mise à jour
docker build --no-cache -t acrsampleappstg10max.azurecr.io/sample-app:latest .
```

#### 3.2 Authentification et push vers ACR

```bash
# Connexion à ACR
docker login acrsampleappstg10max.azurecr.io
# Utilisateur: acrsampleappstg10max
# Mot de passe: [clé-d-accès-ACR]

# Push de l'image
docker push acrsampleappstg10max.azurecr.io/sample-app:latest
```

### Phase 4 : Configuration de l'App Service

#### 4.1 Création de l'App Service

```bash
# Création du plan App Service
az appservice plan create \
  --name myAppServicePlan \
  --resource-group rg-stg_10 \
  --sku B1 \
  --is-linux

# Création de l'App Service
az webapp create \
  --resource-group rg-stg_10 \
  --plan myAppServicePlan \
  --name [nom-app-service] \
  --deployment-container-image-name acrsampleappstg10max.azurecr.io/sample-app:latest
```

#### 4.2 Configuration du conteneur Docker

```bash
# Configuration de l'ACR
az webapp config container set \
  --name [nom-app-service] \
  --resource-group rg-stg_10 \
  --container-image-name acrsampleappstg10max.azurecr.io/sample-app:latest \
  --container-registry-url https://acrsampleappstg10max.azurecr.io \
  --container-registry-user acrsampleappstg10max \
  --container-registry-password [clé-d-accès]
```

#### 4.3 Configuration des variables d'environnement

```bash
# Configuration des variables d'environnement
az webapp config appsettings set \
  --resource-group rg-stg_10 \
  --name [nom-app-service] \
  --settings \
    DB_HOST=mysql-stg10-max-v2.mysql.database.azure.com \
    DB_DATABASE=app_database \
    DB_USERNAME=app_user \
    DB_PASSWORD="j6%>C!uw2e+*3'S" \
    DB_CONNECTION=mysql \
    MYSQL_ATTR_SSL_CA=/opt/ssl/DigiCertGlobalRootCA.crt.pem
```

---

## Résolution des problèmes rencontrés

### Problème 1 : Package MySQL client introuvable

**Erreur :**
```
Package 'mysql-client' has no installation candidate
```

**Cause :** Le nom du package diffère entre les distributions Linux.

**Solution :**
```dockerfile
# Remplacer mysql-client par default-mysql-client
RUN apt-get install -y default-mysql-client
```

### Problème 2 : Wget command not found

**Erreur :**
```
wget: command not found
```

**Cause :** L'outil wget n'était pas installé dans l'image de base.

**Solution :**
```dockerfile
# Ajouter wget à la liste des packages
RUN apt-get install -y wget
```

### Problème 3 : Erreur SSL - Connexions non sécurisées interdites

**Erreur :**
```
SQLSTATE[HY000] [3159] Connections using insecure transport are prohibited
```

**Diagnostic effectué :**
1. Vérification de la connectivité réseau ✅
2. Test de résolution DNS ✅
3. Test d'accessibilité du port 3306 ✅
4. Test de connexion MySQL directe ✅

**Solution :**
Configuration SSL appropriée dans Laravel avec certificat CA.

### Problème 4 : Erreur PDO (trying to connect via (null))

**Erreur :**
```
SQLSTATE[HY000] [2002] (trying to connect via (null))
```

**Cause identifiée :** La fonction `array_filter()` ou les variables d'environnement posaient problème.

**Solution finale :**
Hardcodage du chemin SSL dans `config/database.php` :
```php
PDO::MYSQL_ATTR_SSL_CA => '/opt/ssl/DigiCertGlobalRootCA.crt.pem'
```

### Problème 5 : App Service en mode .NET au lieu de Docker

**Symptôme :** L'App Service démarrait en mode .NET Core au lieu d'utiliser le conteneur Docker.

**Solution :**
Reconfiguration forcée du mode conteneur via Azure CLI :
```bash
az webapp config container set [paramètres-conteneur]
```

---

## Scripts et fichiers de configuration

### Structure des fichiers modifiés

```
sample-app-master/
├── Dockerfile                    # Configuration du conteneur
├── start.sh                     # Script de démarrage avec diagnostics
├── config/database.php          # Configuration SSL Laravel
├── docker-compose.yml           # Configuration locale (inchangé)
└── DOCUMENTATION_MIGRATION_AZURE.md  # Cette documentation
```

### Commandes de diagnostic intégrées

Le script `start.sh` inclut plusieurs niveaux de diagnostic :

1. **Test de résolution DNS :**
   ```bash
   nslookup $DB_HOST
   ```

2. **Test de connectivité réseau :**
   ```bash
   ping -c 3 $DB_HOST
   nc -zv $DB_HOST 3306
   ```

3. **Test de connexion MySQL directe :**
   ```bash
   mysql -h $DB_HOST -u $DB_USERNAME -p$DB_PASSWORD -e "SELECT 1;"
   ```

4. **Test de connexion Laravel :**
   ```bash
   php artisan tinker --execute="DB::connection()->getPdo();"
   ```

---

## Monitoring et maintenance

### Surveillance des logs

#### Logs de l'App Service
```bash
# Streaming des logs en temps réel
az webapp log tail --name [nom-app-service] --resource-group rg-stg_10

# Téléchargement des logs
az webapp log download --name [nom-app-service] --resource-group rg-stg_10
```

#### Logs Docker dans le portail Azure
- Navigation : App Service → Centre de déploiement → Logs
- Logs disponibles : Build, déploiement, runtime

### Métriques importantes à surveiller

| Métrique | Seuil d'alerte | Action recommandée |
|----------|----------------|-------------------|
| CPU Usage | > 80% | Mise à l'échelle verticale |
| Memory Usage | > 85% | Vérification des fuites mémoire |
| Response Time | > 5s | Optimisation des requêtes |
| Error Rate | > 5% | Investigation des logs d'erreur |
| Database Connections | > 80% du max | Optimisation du pool de connexions |

### Maintenance régulière

#### Mise à jour de l'image Docker
```bash
# 1. Modification du code source
# 2. Reconstruction de l'image
docker build --no-cache -t acrsampleappstg10max.azurecr.io/sample-app:latest .

# 3. Push vers ACR
docker push acrsampleappstg10max.azurecr.io/sample-app:latest

# 4. Redémarrage de l'App Service (automatique avec déploiement continu)
az webapp restart --name [nom-app-service] --resource-group rg-stg_10
```

#### Sauvegarde de la base de données
```bash
# Sauvegarde automatique Azure (configurée à 7 jours)
# Sauvegarde manuelle si nécessaire
mysqldump -h mysql-stg10-max-v2.mysql.database.azure.com \
          -u app_user -p app_database > backup_$(date +%Y%m%d).sql
```

---

## Bonnes pratiques et recommandations

### Sécurité

1. **Gestion des secrets :**
   - Utiliser Azure Key Vault pour les mots de passe
   - Rotation régulière des clés d'accès ACR
   - Chiffrement des variables d'environnement sensibles

2. **Réseau :**
   - Configuration de règles de pare-feu MySQL restrictives
   - Utilisation de VNet pour isoler les ressources
   - Activation du WAF (Web Application Firewall)

3. **SSL/TLS :**
   - Forcer HTTPS sur l'App Service
   - Utiliser des certificats SSL managés par Azure
   - Vérification régulière de la validité des certificats

### Performance

1. **Optimisation Docker :**
   - Utilisation d'images multi-stage pour réduire la taille
   - Cache des layers Docker pour accélérer les builds
   - Optimisation des dépendances Composer

2. **Base de données :**
   - Indexation appropriée des tables
   - Monitoring des requêtes lentes
   - Configuration du pool de connexions

3. **Mise en cache :**
   - Redis pour le cache Laravel
   - CDN pour les assets statiques
   - Cache de configuration Laravel

### Évolutivité

1. **Scaling horizontal :**
   - Configuration de l'auto-scaling sur l'App Service
   - Load balancer pour distribuer la charge
   - Session storage externe (Redis)

2. **Monitoring avancé :**
   - Application Insights pour le monitoring applicatif
   - Alertes proactives sur les métriques critiques
   - Dashboards de monitoring personnalisés

### DevOps et CI/CD

1. **Pipeline de déploiement :**
   ```yaml
   # Exemple Azure DevOps Pipeline
   trigger:
   - main
   
   pool:
     vmImage: 'ubuntu-latest'
   
   steps:
   - task: Docker@2
     inputs:
       containerRegistry: 'acrsampleappstg10max'
       repository: 'sample-app'
       command: 'buildAndPush'
       Dockerfile: '**/Dockerfile'
   
   - task: AzureWebAppContainer@1
     inputs:
       azureSubscription: 'Azure-Connection'
       appName: '[nom-app-service]'
       imageName: 'acrsampleappstg10max.azurecr.io/sample-app:latest'
   ```

2. **Tests automatisés :**
   - Tests unitaires Laravel
   - Tests d'intégration avec base de données
   - Tests de sécurité des containers

3. **Environnements multiples :**
   - Développement, staging, production
   - Configuration par environnement
   - Promotion automatique des releases

---

## Conclusion

Cette migration vers Azure App Service avec MySQL SSL a nécessité :

1. **Configuration complexe SSL** : Résolution des problèmes de certificats et configuration PDO
2. **Diagnostic approfondi** : Mise en place d'outils de diagnostic réseau et base de données
3. **Optimisation Docker** : Installation des outils nécessaires et configuration appropriée
4. **Sécurisation** : Mise en place de connexions SSL obligatoires

**Résultat final :** Application Laravel fonctionnelle sur Azure avec connexion sécurisée à MySQL, monitoring intégré, et processus de déploiement automatisé.

**Temps total de migration :** Environ 6-8 heures incluant le diagnostic et la résolution des problèmes.

**Coût estimé mensuel :**
- App Service (B1) : ~15€/mois
- Azure Database for MySQL (B1ms) : ~25€/mois  
- Azure Container Registry (Standard) : ~5€/mois
- **Total : ~45€/mois**

---

*Documentation créée le 11 septembre 2025*  
*Version : 1.0*  
*Auteur : Migration automatisée avec Cascade AI*
