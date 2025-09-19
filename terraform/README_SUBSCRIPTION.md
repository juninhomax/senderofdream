# Configuration de la Subscription Azure pour Terraform

## Problème actuel
Votre Azure CLI local n'a accès qu'à la subscription "Azure for Students" mais pas à "Sub T-CLO" où se trouve le groupe de ressources `rg-stg_10`.

## Solutions possibles

### Option 1: Authentification complète (Recommandée)
```bash
# Se déconnecter complètement
az logout

# Se reconnecter avec le compte qui a accès aux deux subscriptions
az login

# Vérifier l'accès aux subscriptions
az account list --output table

# Définir la subscription par défaut
az account set --subscription "6b9318b1-2215-418a-b0fd-ba0832e9b333"
```

### Option 2: Utiliser Azure Cloud Shell
Puisque Azure Cloud Shell a accès aux deux subscriptions, vous pouvez :

1. Copier les fichiers Terraform vers Cloud Shell
2. Exécuter Terraform depuis Cloud Shell

### Option 3: Authentification avec Service Principal
Créer un service principal avec accès à la subscription "Sub T-CLO" :

```bash
# Depuis Azure Cloud Shell avec la bonne subscription
az account set --subscription "6b9318b1-2215-418a-b0fd-ba0832e9b333"

# Créer un service principal
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" --scopes="/subscriptions/6b9318b1-2215-418a-b0fd-ba0832e9b333"
```

Puis configurer les variables d'environnement :
```bash
export ARM_CLIENT_ID="<appId>"
export ARM_CLIENT_SECRET="<password>"
export ARM_SUBSCRIPTION_ID="6b9318b1-2215-418a-b0fd-ba0832e9b333"
export ARM_TENANT_ID="901cb4ca-b862-4029-9306-e5cd0f6d9f86"
```

## Configuration Terraform actuelle
Le fichier `terraform.tfvars` est configuré pour utiliser la subscription "Sub T-CLO" :
- Subscription ID: `6b9318b1-2215-418a-b0fd-ba0832e9b333`
- Groupe de ressources: `rg-stg_10`
- Région: `France Central`

## Prochaines étapes
1. Choisir une des options ci-dessus
2. Vérifier l'accès à la subscription avec `az account show`
3. Vérifier l'existence du groupe `rg-stg_10` avec `az group show --name "rg-stg_10"`
4. Lancer `terraform plan` pour valider la configuration
