#!/bin/bash

# Local Testing Script
# This script helps you test the application locally before pushing to GitHub

echo "🧪 Starting Local Tests..."
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo "❌ .env file not found!"
    echo "📝 Creating .env from .env.example..."
    cp .env.example .env
    echo "⚠️  Please edit .env and add your Discord webhook URL"
    echo "   Then run this script again"
    exit 1
fi

# Source environment variables
export $(cat .env | grep -v '^#' | xargs)

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "   Please start Docker Desktop and try again"
    exit 1
fi
echo "✅ Docker is running"

# Check if Kubernetes is running
if ! kubectl cluster-info > /dev/null 2>&1; then
    echo "❌ Kubernetes is not running!"
    echo "   Please enable Kubernetes in Docker Desktop settings"
    exit 1
fi
echo "✅ Kubernetes is running"

# Build Docker image
echo ""
echo "🐳 Building Docker image..."
docker build -t jenkins-discord-app:test . || exit 1
echo "✅ Docker image built successfully"

# Test with Docker
echo ""
echo "🧪 Testing with Docker..."
docker run --rm -e DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL}" jenkins-discord-app:test
echo ""

# Ask if user wants to deploy to Kubernetes
read -p "Deploy to local Kubernetes? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Deploying to Kubernetes..."
    
    # Create namespace
    kubectl create namespace jenkins-app --dry-run=client -o yaml | kubectl apply -f -
    
    # Create secret
    kubectl create secret generic discord-webhook \
        --from-literal=DISCORD_WEBHOOK_URL="${DISCORD_WEBHOOK_URL}" \
        --namespace=jenkins-app \
        --dry-run=client -o yaml | kubectl apply -f -
    
    # Update deployment with test tag
    sed 's/BUILD_NUMBER/test/g' deployment.yaml > deployment-test.yaml
    
    # Apply deployment
    kubectl apply -f deployment-test.yaml
    
    # Wait for deployment
    echo "⏳ Waiting for deployment..."
    kubectl rollout status deployment/jenkins-discord-app -n jenkins-app --timeout=2m
    
    # Show status
    echo ""
    echo "📊 Deployment Status:"
    kubectl get pods -n jenkins-app
    
    # Show logs
    echo ""
    echo "📋 Application Logs:"
    POD_NAME=$(kubectl get pods -n jenkins-app -l app=jenkins-discord-app -o jsonpath='{.items[0].metadata.name}')
    kubectl logs $POD_NAME -n jenkins-app
    
    # Cleanup
    rm -f deployment-test.yaml
    
    echo ""
    echo "✅ Local Kubernetes deployment complete!"
    echo ""
    echo "To cleanup: kubectl delete namespace jenkins-app"
fi

echo ""
echo "🎉 All tests completed!"
