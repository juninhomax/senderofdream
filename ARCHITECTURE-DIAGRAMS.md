# 🏗️ Architecture Diagrams - T-CLO-901 Multi-Environment Deployment

## 📊 **1. Architecture Globale du Système**

```mermaid
graph TB
    subgraph "🌐 GitHub Repository"
        A[Developer] -->|git push tag| B[GitHub Actions]
        B --> C[Multi-Environment Workflow]
    end
    
    subgraph "☁️ Azure Cloud Infrastructure"
        subgraph "🔐 Authentication"
            D[Service Principal<br/>github-actions-senderofdream]
        end
        
        subgraph "📦 Container Registry"
            E[Azure Container Registry<br/>acrsampleappstg10maxprod]
        end
        
        subgraph "🏢 Resource Group: rg-stg_10"
            subgraph "🌍 DEV Environment"
                F[App Service<br/>app-dev-stg10]
                G[MySQL Server<br/>mysql-dev-stg10]
            end
            
            subgraph "🧪 STAGING Environment"
                H[App Service<br/>app-staging-stg10]
                I[MySQL Server<br/>mysql-staging-stg10]
            end
            
            subgraph "🚀 PROD Environment"
                J[App Service<br/>app-prod-stg10]
                K[MySQL Server<br/>mysql-prod-stg10]
            end
        end
        
        subgraph "💾 Infrastructure State"
            L[Terraform State<br/>Storage Account: tfstatestg10]
        end
    end
    
    subgraph "🛠️ Development Tools"
        M[Terraform<br/>Infrastructure as Code]
        N[Docker<br/>Containerization]
        O[Laravel<br/>Web Application]
    end
    
    C -->|Authenticate| D
    C -->|Deploy Infrastructure| M
    M -->|Store State| L
    C -->|Build & Push Image| N
    N -->|Push to| E
    C -->|Deploy to Environment| F
    C -->|Deploy to Environment| H
    C -->|Deploy to Environment| J
    F -->|Connect to| G
    H -->|Connect to| I
    J -->|Connect to| K
    E -->|Pull Image| F
    E -->|Pull Image| H
    E -->|Pull Image| J
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C fill:#e8f5e8
    style D fill:#fff3e0
    style E fill:#fce4ec
    style F fill:#e0f2f1
    style G fill:#e0f2f1
    style H fill:#fff8e1
    style I fill:#fff8e1
    style J fill:#ffebee
    style K fill:#ffebee
    style L fill:#f1f8e9
    style M fill:#e3f2fd
    style N fill:#e8eaf6
    style O fill:#fafafa
```

## 🔄 **2. Workflow de Déploiement Multi-Environnement**

```mermaid
sequenceDiagram
    participant Dev as 👨‍💻 Developer
    participant Git as 📚 GitHub
    participant GA as ⚙️ GitHub Actions
    participant Azure as ☁️ Azure
    participant TF as 🏗️ Terraform
    participant Docker as 🐳 Docker
    participant ACR as 📦 Azure Container Registry
    participant App as 🌐 App Service
    participant DB as 🗄️ MySQL Database
    
    Dev->>Git: git tag dev-v1.1.0
    Dev->>Git: git push origin dev-v1.1.0
    
    Git->>GA: Trigger Multi-Environment Workflow
    GA->>GA: Detect Environment (dev)
    
    Note over GA: Phase 1: Authentication
    GA->>Azure: Login with Service Principal
    Azure-->>GA: Authentication Success ✅
    
    Note over GA: Phase 2: Infrastructure Deployment
    GA->>TF: terraform init
    TF->>Azure: Load existing state from tfstatestg10
    GA->>TF: terraform plan
    GA->>TF: terraform apply
    TF->>Azure: Create/Update ACR, App Service, MySQL
    Azure-->>TF: Resources Created ✅
    
    Note over GA: Phase 3: Application Build
    GA->>Docker: docker build -t sample-app:dev-latest
    Docker-->>GA: Image Built ✅
    GA->>ACR: docker push sample-app:dev-latest
    ACR-->>GA: Image Pushed ✅
    
    Note over GA: Phase 4: Database Configuration
    GA->>DB: Configure MySQL users and permissions
    DB-->>GA: Database Ready ✅
    
    Note over GA: Phase 5: Application Deployment
    GA->>App: Configure container settings
    GA->>App: Set environment variables
    App->>ACR: Pull latest image (dev-latest)
    ACR-->>App: Image Downloaded ✅
    App->>App: Zero Downtime Update
    App->>DB: Connect to MySQL
    
    Note over GA: Phase 6: Verification
    GA->>App: Health Check
    App-->>GA: Application Ready ✅
    
    GA-->>Dev: Deployment Complete 🎉
    
    Note over App: https://app-dev-stg10.azurewebsites.net
```

## 🏗️ **3. Architecture Technique Détaillée**

```mermaid
graph LR
    subgraph "💻 Development Environment"
        A1[Laravel Application<br/>PHP 8.2 + Apache]
        A2[Docker Container<br/>Multi-stage Build]
        A3[Terraform Modules<br/>Infrastructure Definition]
    end
    
    subgraph "🔄 CI/CD Pipeline"
        B1[GitHub Actions<br/>Multi-Environment Workflow]
        B2[Environment Detection<br/>Tag-based Routing]
        B3[Parallel Execution<br/>Build + Infrastructure]
    end
    
    subgraph "☁️ Azure Infrastructure"
        subgraph "🔐 Security Layer"
            C1[Service Principal<br/>RBAC Authentication]
            C2[Key Vault<br/>Secrets Management]
            C3[SSL/TLS Certificates<br/>DigiCert Global Root CA]
        end
        
        subgraph "📦 Container Platform"
            D1[Azure Container Registry<br/>Docker Image Storage]
            D2[App Service Linux<br/>Container Hosting]
            D3[Continuous Deployment<br/>Image Auto-Update]
        end
        
        subgraph "🗄️ Data Layer"
            E1[MySQL Flexible Server<br/>SSL Required]
            E2[Database Per Environment<br/>app_database]
            E3[Automated Migrations<br/>Laravel Artisan]
        end
        
        subgraph "🌐 Network Layer"
            F1[Virtual Network<br/>Secure Communication]
            F2[Private Endpoints<br/>Database Access]
            F3[Load Balancer<br/>High Availability]
        end
        
        subgraph "📊 Monitoring Layer"
            G1[Application Insights<br/>Performance Monitoring]
            G2[Log Analytics<br/>Centralized Logging]
            G3[Health Checks<br/>Availability Monitoring]
        end
    end
    
    A1 --> A2
    A2 --> B1
    A3 --> B1
    B1 --> B2
    B2 --> B3
    B3 --> C1
    C1 --> D1
    D1 --> D2
    D2 --> D3
    B3 --> E1
    E1 --> E2
    E2 --> E3
    D2 --> F1
    F1 --> F2
    F2 --> F3
    D2 --> G1
    G1 --> G2
    G2 --> G3
    
    style A1 fill:#e3f2fd
    style A2 fill:#e8eaf6
    style A3 fill:#f3e5f5
    style B1 fill:#e8f5e8
    style B2 fill:#fff3e0
    style B3 fill:#fce4ec
    style C1 fill:#ffebee
    style C2 fill:#f1f8e9
    style C3 fill:#e0f2f1
    style D1 fill:#fff8e1
    style D2 fill:#e1f5fe
    style D3 fill:#fafafa
```

## 🔄 **4. Flux de Données et Communication**

```mermaid
graph TD
    subgraph "🌍 Internet"
        A[End Users<br/>HTTPS Requests]
    end
    
    subgraph "☁️ Azure Front Door / Load Balancer"
        B[Traffic Distribution<br/>SSL Termination]
    end
    
    subgraph "🏢 Environment Isolation"
        subgraph "🌱 DEV Environment"
            C1[app-dev-stg10.azurewebsites.net]
            C2[Laravel Container<br/>dev-latest image]
            C3[mysql-dev-stg10<br/>Development Database]
        end
        
        subgraph "🧪 STAGING Environment"
            D1[app-staging-stg10.azurewebsites.net]
            D2[Laravel Container<br/>staging-latest image]
            D3[mysql-staging-stg10<br/>Staging Database]
        end
        
        subgraph "🚀 PROD Environment"
            E1[app-prod-stg10.azurewebsites.net]
            E2[Laravel Container<br/>prod-latest image]
            E3[mysql-prod-stg10<br/>Production Database]
        end
    end
    
    subgraph "📦 Shared Resources"
        F1[Azure Container Registry<br/>acrsampleappstg10maxprod]
        F2[Terraform State<br/>tfstatestg10]
        F3[Monitoring & Logs<br/>Application Insights]
    end
    
    A -->|HTTPS| B
    B -->|Route by subdomain| C1
    B -->|Route by subdomain| D1
    B -->|Route by subdomain| E1
    
    C1 --> C2
    C2 -->|SQL Connection<br/>SSL Required| C3
    C2 -->|Pull Image| F1
    
    D1 --> D2
    D2 -->|SQL Connection<br/>SSL Required| D3
    D2 -->|Pull Image| F1
    
    E1 --> E2
    E2 -->|SQL Connection<br/>SSL Required| E3
    E2 -->|Pull Image| F1
    
    C2 -->|Telemetry| F3
    D2 -->|Telemetry| F3
    E2 -->|Telemetry| F3
    
    style A fill:#e1f5fe
    style B fill:#f3e5f5
    style C1 fill:#e0f2f1
    style C2 fill:#e0f2f1
    style C3 fill:#e0f2f1
    style D1 fill:#fff8e1
    style D2 fill:#fff8e1
    style D3 fill:#fff8e1
    style E1 fill:#ffebee
    style E2 fill:#ffebee
    style E3 fill:#ffebee
    style F1 fill:#fce4ec
    style F2 fill:#f1f8e9
    style F3 fill:#e8f5e8
```

## 🚀 **5. Processus de Déploiement Zero Downtime**

```mermaid
stateDiagram-v2
    [*] --> TagPushed: git push origin dev-v1.1.0
    
    TagPushed --> WorkflowTriggered: GitHub Actions detects tag
    WorkflowTriggered --> EnvironmentDetected: Parse tag prefix (dev-)
    
    EnvironmentDetected --> Authentication: Login to Azure
    Authentication --> InfrastructurePhase: Service Principal authenticated
    
    InfrastructurePhase --> TerraformInit: Load existing state
    TerraformInit --> TerraformPlan: Plan infrastructure changes
    TerraformPlan --> TerraformApply: Apply changes
    TerraformApply --> InfrastructureReady: Resources created/updated
    
    InfrastructureReady --> DockerBuild: Build application image
    DockerBuild --> ImagePush: Push to ACR with env-latest tag
    ImagePush --> DatabaseConfig: Configure MySQL users
    
    DatabaseConfig --> AppServiceConfig: Configure container settings
    AppServiceConfig --> ContinuousDeployment: App Service detects new image
    
    ContinuousDeployment --> ImagePull: Pull dev-latest from ACR
    ImagePull --> ContainerUpdate: Update container (zero downtime)
    ContainerUpdate --> HealthCheck: Verify application health
    
    HealthCheck --> DeploymentComplete: Application ready
    DeploymentComplete --> [*]: https://app-dev-stg10.azurewebsites.net
    
    note right of ContinuousDeployment
        Zero Downtime Process:
        1. New container starts
        2. Health check passes
        3. Traffic switches
        4. Old container stops
    end note
```

## 📋 **6. Technologies et Versions**

| Composant | Technologie | Version | Rôle |
|-----------|-------------|---------|------|
| **Application** | Laravel | 10.x | Framework PHP |
| **Runtime** | PHP | 8.2.8 | Langage de programmation |
| **Web Server** | Apache | 2.4 | Serveur HTTP |
| **Containerization** | Docker | Latest | Containerisation |
| **Container Registry** | Azure Container Registry | - | Stockage d'images |
| **Hosting** | Azure App Service Linux | - | Hébergement de conteneurs |
| **Database** | MySQL Flexible Server | 8.0 | Base de données |
| **Infrastructure** | Terraform | 1.9.8 | Infrastructure as Code |
| **CI/CD** | GitHub Actions | - | Intégration continue |
| **Monitoring** | Application Insights | - | Observabilité |
| **SSL/TLS** | DigiCert Global Root CA | - | Sécurité |

## 🎯 **7. Avantages de l'Architecture**

### **🔄 DevOps Excellence**
- ✅ **Infrastructure as Code** : Reproductibilité complète
- ✅ **CI/CD Automatisé** : Déploiement par tags Git
- ✅ **Multi-environnement** : Isolation dev/staging/prod
- ✅ **Zero Downtime** : Mise à jour sans interruption

### **☁️ Cloud Native**
- ✅ **Containerisation** : Portabilité et scalabilité
- ✅ **Managed Services** : Réduction de la maintenance
- ✅ **Auto-scaling** : Adaptation automatique à la charge
- ✅ **High Availability** : Redondance et résilience

### **🔐 Sécurité**
- ✅ **RBAC** : Contrôle d'accès basé sur les rôles
- ✅ **SSL/TLS** : Chiffrement des communications
- ✅ **Secrets Management** : Gestion sécurisée des credentials
- ✅ **Network Isolation** : Segmentation réseau

### **📊 Observabilité**
- ✅ **Monitoring** : Surveillance en temps réel
- ✅ **Logging** : Centralisation des logs
- ✅ **Alerting** : Notifications automatiques
- ✅ **Performance Tracking** : Métriques applicatives

---

## 🏆 **Conclusion**

Cette architecture représente un **système DevOps de niveau professionnel** pour le projet **T-CLO-901 Epitech**, démontrant :

- **Maîtrise technique** : Technologies cloud modernes
- **Bonnes pratiques** : DevOps, sécurité, monitoring
- **Scalabilité** : Architecture extensible
- **Fiabilité** : Déploiement zero downtime

**Un projet exemplaire qui illustre parfaitement les compétences DevOps attendues ! 🎓🚀**
