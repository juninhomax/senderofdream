#!/bin/bash

# Laravel Azure deployment script with full automation
# Usage:
#   ./deploy.sh                    - Deploy infrastructure only
#   ./deploy.sh all               - Deploy infrastructure + application (fully automated)
#   ./deploy.sh configure         - Configure application only (requires existing infrastructure)
#   ./deploy.sh destroy           - Destroy all infrastructure
#   ./deploy.sh plan              - Show Terraform plan

show_help() {
    echo "Laravel Azure Deployment Script"
    echo ""
    echo "Usage: ./deploy.sh [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  (no args)         Deploy infrastructure only"
    echo "  infra              Deploy infrastructure only"
    echo "  all, complete      Deploy infrastructure + application (fully automated)"
    echo "  configure, app     Configure application only (requires existing infrastructure)"
    echo "  destroy            Destroy all infrastructure"
    echo "  plan               Show Terraform plan"
    echo "  help               Show this help message"
    echo ""
    echo "Prerequisites:"
    echo "  - Azure CLI logged in (az login)"
    echo "  - Docker Desktop running"
    echo "  - Terraform installed"
    echo ""
}

# Check Azure authentication
check_auth() {
    echo "Checking Azure authentication..."
    if ! az account show > /dev/null 2>&1; then
        echo "❌ Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Verify we can get an access token (session not expired)
    if ! az account get-access-token > /dev/null 2>&1; then
        echo "❌ Azure session expired. Please run 'az login' again."
        exit 1
    fi
    
    echo "✅ Azure authentication verified."
}

# Enhanced ACR authentication check
check_acr_auth() {
    local acr_name=$1
    echo "🔐 Verifying ACR authentication for $acr_name..."
    
    # Try to login to ACR
    if ! az acr login --name $acr_name; then
        echo "❌ Failed to authenticate with ACR. Retrying..."
        
        # Get fresh credentials and try again
        local acr_username=$(az acr credential show --name $acr_name --query "username" -o tsv)
        local acr_password=$(az acr credential show --name $acr_name --query "passwords[0].value" -o tsv)
        
        if ! echo $acr_password | docker login $acr_name.azurecr.io --username $acr_username --password-stdin; then
            echo "❌ ACR authentication failed completely. Please check your permissions."
            exit 1
        fi
    fi
    
    echo "✅ ACR authentication successful."
}

# Check Docker is running
check_docker() {
    echo "🐳 Checking Docker status..."
    if ! docker info > /dev/null 2>&1; then
        echo "❌ Docker is not running. Please start Docker Desktop and try again."
        exit 1
    fi
    echo "✅ Docker is running."
}

# Deploy infrastructure with Terraform
deploy_infrastructure() {
    echo "🚀 Starting infrastructure deployment..."
    check_auth
    
    echo "📦 Deploying infrastructure with Terraform..."
    terraform init
    terraform plan
    read -p "Continue with terraform apply? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Deployment cancelled"
        exit 0
    fi
    
    terraform apply
    
    echo ""
    echo "✅ Infrastructure deployment completed!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Verify resources are created in Azure portal"
    echo "2. Run: ./deploy.sh ansible  (to configure the application)"
    echo ""
    echo "🌐 Application URL (once configured): $(terraform output -raw app_service_url)"
}

# Configure application automatically with all fixes applied
configure_application() {
    echo "🔧 Starting application configuration..."
    check_auth
    check_docker
    
    # Check if infrastructure exists
    if ! terraform output app_service_url > /dev/null 2>&1; then
        echo "❌ Infrastructure not found. Run './deploy.sh' first to deploy infrastructure."
        exit 1
    fi
    
    echo "🔧 Configuring application automatically..."
    
    # Get Terraform outputs
    echo "📋 Getting infrastructure information..."
    ACR_NAME=$(terraform output -raw acr_name)
    ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server)
    APP_SERVICE_NAME=$(terraform output -raw app_service_name)
    RESOURCE_GROUP=$(terraform output -raw resource_group_name)
    MYSQL_HOST=$(terraform output -raw mysql_server_fqdn)
    MYSQL_ADMIN_PASSWORD=$(terraform output -raw mysql_admin_password)
    MYSQL_APP_PASSWORD=$(terraform output -raw mysql_app_password)
    LARAVEL_APP_KEY=$(terraform output -raw laravel_app_key)
    
    # Get ACR credentials
    echo "🔑 Getting ACR credentials..."
    ACR_USERNAME=$(az acr credential show --name $ACR_NAME --query "username" -o tsv)
    ACR_PASSWORD=$(az acr credential show --name $ACR_NAME --query "passwords[0].value" -o tsv)
    
    # Verify ACR authentication
    check_acr_auth $ACR_NAME
    
    # Build and push Docker image from the correct directory
    echo "🐳 Building Docker image..."
    cd ../
    if ! docker build -t $ACR_LOGIN_SERVER/sample-app:latest .; then
        echo "❌ Docker build failed!"
        cd terraform/
        exit 1
    fi
    
    echo "📤 Pushing image to ACR..."
    if ! docker push $ACR_LOGIN_SERVER/sample-app:latest; then
        echo "❌ Docker push failed!"
        cd terraform/
        exit 1
    fi
    cd terraform/
    
    # Verify image was pushed successfully
    echo "✅ Verifying image in ACR..."
    if ! az acr repository show --name $ACR_NAME --repository sample-app > /dev/null 2>&1; then
        echo "❌ Image not found in ACR after push!"
        exit 1
    fi
    echo "✅ Image successfully pushed to ACR."
    
    # Create MySQL app user
    echo "👤 Creating MySQL app user..."
    az mysql flexible-server execute \
        --name $(terraform output -raw mysql_server_name) \
        --admin-user adminuser \
        --admin-password $MYSQL_ADMIN_PASSWORD \
        --database-name app_database \
        --querytext "CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY '$MYSQL_APP_PASSWORD';"
    
    az mysql flexible-server execute \
        --name $(terraform output -raw mysql_server_name) \
        --admin-user adminuser \
        --admin-password $MYSQL_ADMIN_PASSWORD \
        --database-name app_database \
        --querytext "GRANT ALL PRIVILEGES ON app_database.* TO 'app_user'@'%';"
    
    az mysql flexible-server execute \
        --name $(terraform output -raw mysql_server_name) \
        --admin-user adminuser \
        --admin-password $MYSQL_ADMIN_PASSWORD \
        --database-name app_database \
        --querytext "FLUSH PRIVILEGES;"
    
    # Create configuration JSON file
    echo "⚙️  Creating App Service configuration..."
    cat > app-config-auto.json << EOF
{
  "properties": {
    "DOCKER_REGISTRY_SERVER_URL": "https://$ACR_LOGIN_SERVER",
    "DOCKER_REGISTRY_SERVER_USERNAME": "$ACR_USERNAME",
    "DOCKER_REGISTRY_SERVER_PASSWORD": "$ACR_PASSWORD",
    "DB_CONNECTION": "mysql",
    "DB_HOST": "$MYSQL_HOST",
    "DB_DATABASE": "app_database",
    "DB_USERNAME": "app_user",
    "DB_PASSWORD": "$MYSQL_APP_PASSWORD",
    "APP_ENV": "production",
    "APP_DEBUG": "false",
    "APP_KEY": "$LARAVEL_APP_KEY",
    "MYSQL_ATTR_SSL_CA": "/opt/ssl/DigiCertGlobalRootCA.crt.pem",
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE": "false",
    "WEBSITES_PORT": "80"
  }
}
EOF
    
    # Configure App Service via REST API (more reliable than Azure CLI)
    echo "🔧 Configuring App Service environment variables..."
    ACCESS_TOKEN=$(az account get-access-token --query accessToken -o tsv)
    SUBSCRIPTION_ID="6b9318b1-2215-418a-b0fd-ba0832e9b333"
    
    curl -X PUT \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d @app-config-auto.json \
        "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_SERVICE_NAME/config/appsettings?api-version=2022-03-01"
    
    # Configure container settings
    echo "🐳 Configuring container settings..."
    az webapp config container set \
        --resource-group $RESOURCE_GROUP \
        --name $APP_SERVICE_NAME \
        --container-image-name $ACR_LOGIN_SERVER/sample-app:latest \
        --container-registry-url https://$ACR_LOGIN_SERVER \
        --container-registry-user $ACR_USERNAME \
        --container-registry-password $ACR_PASSWORD
    
    # Restart App Service
    echo "🔄 Restarting App Service..."
    az webapp restart --resource-group $RESOURCE_GROUP --name $APP_SERVICE_NAME
    
    echo "⏳ Waiting for application to start..."
    sleep 60
    
    # Clean up temporary files
    rm -f app-config-auto.json
    
    echo ""
    echo "🎉 Application configuration completed!"
    echo "🌐 Application URL: $(terraform output -raw app_service_url)"
    echo ""
    echo "📋 Next steps:"
    echo "1. Wait a few minutes for the application to fully start"
    echo "2. Test the application at the URL above"
    echo "3. Check logs if needed: az webapp log tail --name $APP_SERVICE_NAME --resource-group $RESOURCE_GROUP"
}

# Deploy ACR first, trigger build, then deploy rest
deploy_all() {
    echo "🚀 Starting phased deployment..."
    
    # Phase 1: Deploy ACR only
    deploy_acr_first
    
    # Phase 2: Trigger GitHub Actions build
    trigger_github_actions_build
    
    # Phase 3: Wait for image
    wait_for_image_in_acr
    
    # Phase 4: Deploy rest of infrastructure
    deploy_rest_of_infrastructure
    
    # Phase 5: Configure application
    configure_application
    
    echo ""
    echo "🎉 Complete phased deployment finished!"
    echo "🌐 Your Laravel application is ready at: $(terraform output -raw app_service_url)"
}

# Deploy only ACR
deploy_acr_first() {
    echo "🏗️ Phase 1: Deploying ACR first..."
    check_auth
    
    # Create storage account for Terraform backend if it doesn't exist
    echo "🗄️ Setting up Terraform backend storage..."
    if ! az storage account show --name tfstatestg10 --resource-group rg-stg_10 > /dev/null 2>&1; then
        echo "Creating storage account for Terraform state..."
        az storage account create \
            --name tfstatestg10 \
            --resource-group rg-stg_10 \
            --location francecentral \
            --sku Standard_LRS
        
        az storage container create \
            --name tfstate \
            --account-name tfstatestg10
    fi
    
    terraform init
    terraform apply -target=azurerm_container_registry.main -auto-approve
    
    echo "✅ ACR deployed successfully!"
    echo "⏳ Waiting 2 minutes for ACR to be fully operational..."
    sleep 180
    
    # Verify ACR is ready
    local acr_name=$(terraform output -raw acr_name)
    
    # No need to update GitHub secrets anymore!
    # GitHub Actions will read credentials directly from Terraform state
    echo "✅ ACR credentials available in Terraform state"
    echo "🔄 GitHub Actions will read them automatically from tfstate"
    echo ""
}


# Trigger GitHub Actions workflow
trigger_github_actions_build() {
    echo "🚀 Phase 2: Triggering GitHub Actions build..."
    
    # Simple git push to trigger workflow
    echo "Creating empty commit to trigger build..."
    git commit --allow-empty -m "Trigger build for ACR deployment"
    git push origin $(git branch --show-current)
    
    echo "✅ Build triggered!"
}

# Wait for image to be available in ACR
wait_for_image_in_acr() {
    echo "⏳ Phase 3: Waiting for image to be available in ACR..."
    
    local acr_name=$(terraform output -raw acr_name)
    local max_attempts=20
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Checking attempt $attempt/$max_attempts..."
        
        if az acr repository show --name $acr_name --repository sample-app > /dev/null 2>&1; then
            echo "✅ Image found in ACR!"
            return 0
        fi
        
        echo "Image not ready yet, waiting 30 seconds..."
        sleep 30
        ((attempt++))
    done
    
    echo "❌ Timeout waiting for image in ACR"
    echo "Please check GitHub Actions workflow status"
    exit 1
}

# Deploy rest of infrastructure
deploy_rest_of_infrastructure() {
    echo "🏗️ Phase 4: Deploying rest of infrastructure..."
    
    terraform apply -auto-approve
    
    echo "✅ Infrastructure deployment completed!"
}

# Main script logic
case "${1:-}" in
    "all"|"complete"|"auto")
        deploy_all
        ;;
    "infra"|"infrastructure")
        deploy_infrastructure
        ;;
    "ansible"|"app"|"configure")
        configure_application
        ;;
    "destroy")
        echo "🗑️  Destroying infrastructure..."
        check_auth
        terraform destroy -auto-approve
        echo "✅ Infrastructure destroyed successfully!"
        ;;
    "plan")
        check_auth
        terraform init
        terraform plan
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        deploy_infrastructure
        ;;
esac

