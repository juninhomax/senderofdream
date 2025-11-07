#!/bin/bash

# 🚀 Script de migration vers GitHub Actions Runner
# Ce script aide à migrer du deploy.sh vers le workflow GitHub Actions

echo "🚀 Migration vers GitHub Actions Runner"
echo "======================================"
echo ""

# Vérifier qu'on est sur la bonne branche
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "migrate-deploy-to-runner" ]; then
    echo "⚠️ Vous n'êtes pas sur la branche migrate-deploy-to-runner"
    echo "Voulez-vous basculer ? (y/N)"
    read -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout migrate-deploy-to-runner
    else
        echo "❌ Migration annulée"
        exit 1
    fi
fi

echo "✅ Branche migrate-deploy-to-runner active"
echo ""

# Vérifier les secrets GitHub
echo "🔍 Vérification des prérequis..."
echo ""
echo "📋 Checklist avant migration :"
echo "  ✅ Branche migrate-deploy-to-runner créée"
echo "  ⚠️ Secret AZURE_CREDENTIALS configuré dans GitHub"
echo "  ⚠️ Workflows GitHub Actions activés"
echo "  ⚠️ Permissions sur le repository"
echo ""

# Afficher les différences
echo "📊 Comparaison des approches :"
echo ""
echo "🔴 AVANT (deploy.sh) :"
echo "  1. Cloud Shell / Local"
echo "  2. ./deploy.sh all"
echo "  3. Attendre ~20 minutes"
echo "  4. Configuration manuelle"
echo ""
echo "🟢 MAINTENANT (GitHub Actions) :"
echo "  1. git push origin migrate-deploy-to-runner"
echo "  2. Déploiement automatique"
echo "  3. Logs dans GitHub Actions"
echo "  4. Configuration automatique"
echo ""

# Options de déploiement
echo "🎮 Options de déploiement :"
echo ""
echo "1. 🚀 Déploiement automatique (recommandé)"
echo "   → git push origin migrate-deploy-to-runner"
echo ""
echo "2. 🎯 Déploiement manuel"
echo "   → GitHub → Actions → Full Infrastructure & Application Deployment → Run workflow"
echo ""
echo "3. 📋 Plan Terraform seulement"
echo "   → GitHub → Actions → Run workflow → plan"
echo ""
echo "4. 🗑️ Destruction infrastructure"
echo "   → GitHub → Actions → Run workflow → destroy"
echo ""

# Proposer le déploiement
echo "Voulez-vous déclencher un déploiement maintenant ? (y/N)"
read -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Déclenchement du déploiement..."
    
    # Vérifier s'il y a des changements à commiter
    if ! git diff-index --quiet HEAD --; then
        echo "📝 Changements détectés, commit automatique..."
        git add .
        git commit -m "Migrate to GitHub Actions Runner deployment"
    fi
    
    # Push pour déclencher le workflow
    echo "📤 Push vers GitHub..."
    git push origin migrate-deploy-to-runner
    
    echo ""
    echo "✅ Déploiement déclenché !"
    echo "🔗 Suivez le progrès sur : https://github.com/juninhomax/senderofdream/actions"
    echo ""
    echo "⏱️ Durée estimée : 15-20 minutes"
    echo "🌐 URL finale : https://app-stg10-tf.azurewebsites.net"
    
else
    echo "ℹ️ Déploiement non déclenché"
    echo ""
    echo "📖 Pour déployer plus tard :"
    echo "  git push origin migrate-deploy-to-runner"
    echo ""
    echo "📖 Ou via GitHub UI :"
    echo "  GitHub → Actions → Full Infrastructure & Application Deployment → Run workflow"
fi

echo ""
echo "📚 Documentation :"
echo "  - README-RUNNER-DEPLOYMENT.md"
echo "  - .github/workflows/full-deploy.yml"
echo ""
echo "🎉 Migration terminée !"
