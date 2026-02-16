# 🚀 Jenkins + Docker + Kubernetes CI/CD Pipeline

Complete beginner-friendly CI/CD pipeline that automatically:
- ✅ Detects code changes in GitHub
- ✅ Builds Docker images via Jenkins
- ✅ Deploys to local Kubernetes cluster
- ✅ Sends Discord notifications

---

## 📋 Prerequisites

### 1. Docker Desktop
- Download: https://www.docker.com/products/docker-desktop
- Install and start Docker Desktop
- **Enable Kubernetes**: Settings → Kubernetes → ✅ Enable Kubernetes

### 2. Jenkins
```bash
# Run Jenkins in Docker
docker run -d \
  --name jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube:/root/.kube \
  jenkins/jenkins:lts

# Get initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 3. kubectl in Jenkins
```bash
docker exec -it jenkins bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
exit
```

---

## 🔧 Setup Instructions

### Step 1: Clone or Download This Repository
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
```

### Step 2: Set Up Environment Variables (Local Testing)
```bash
# Copy the example file
cp .env.example .env

# Edit .env and add your Discord webhook URL
# Get webhook from: Discord → Server Settings → Integrations → Webhooks
```

### Step 3: Configure Jenkins

#### A. Install Required Plugins
**Manage Jenkins → Plugins → Available**
- Git Plugin
- GitHub Plugin
- Pipeline Plugin
- Docker Pipeline Plugin
- Kubernetes CLI Plugin

#### B. Add Discord Webhook Credential
**Manage Jenkins → Credentials → Add Credentials**
- Kind: Secret text
- Secret: Your Discord webhook URL
- ID: `discord-webhook`
- Click Create

#### C. Add GitHub Credentials
**Manage Jenkins → Credentials → Add Credentials**
- Kind: Username with password
- Username: Your GitHub username
- Password: Personal Access Token (create at github.com/settings/tokens)
- ID: `github-credentials`
- Click Create

### Step 4: Create Jenkins Pipeline Job
1. **New Item** → Name: `kubernetes-deployment-pipeline` → **Pipeline**
2. **General:**
   - ✅ GitHub project
   - Project url: `https://github.com/YOUR_USERNAME/YOUR_REPO`
3. **Build Triggers:**
   - ✅ GitHub hook trigger for GITScm polling
4. **Pipeline:**
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_USERNAME/YOUR_REPO.git`
   - Credentials: `github-credentials`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`
5. Click **Save**

### Step 5: Configure GitHub Webhook
**GitHub Repository → Settings → Webhooks → Add webhook**
- Payload URL: `http://YOUR_IP:8080/github-webhook/`
- Content type: `application/json`
- Just the push event
- Click Add webhook

---

## 🎯 Usage

### Manual Trigger
```bash
# In Jenkins, click "Build Now"
```

### Auto-Trigger (recommended)
```bash
# Make any code change
echo "# Test" >> README.md

# Commit and push
git add .
git commit -m "Test deployment"
git push origin main

# Jenkins automatically builds and deploys! 🎉
```

---

## 📊 Verify Deployment

```bash
# Check if pods are running
kubectl get pods -n jenkins-app

# View application logs
kubectl logs -l app=jenkins-discord-app -n jenkins-app

# Check deployment status
kubectl get deployment -n jenkins-app

# View all resources
kubectl get all -n jenkins-app
```

---

## 🔍 Troubleshooting

### Issue: kubectl not found in Jenkins
```bash
docker exec -it jenkins bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
exit
```

### Issue: Docker permission denied
```bash
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Issue: Cannot connect to Kubernetes
```bash
# Copy kubeconfig to Jenkins
docker cp ~/.kube jenkins:/var/jenkins_home/.kube
docker exec jenkins chmod -R 755 /var/jenkins_home/.kube
```

### Issue: Image not found in Kubernetes
- Check `imagePullPolicy: Never` in deployment.yaml
- Verify image was built: `docker images | grep jenkins-discord-app`

---

## 📁 Project Structure

```
jenkins-k8s-project/
├── app.py                  # Main Python application
├── requirements.txt        # Python dependencies
├── Dockerfile             # Docker image configuration
├── deployment.yaml        # Kubernetes deployment config
├── Jenkinsfile           # CI/CD pipeline definition
├── .env.example          # Environment variables template
├── .gitignore            # Git ignore rules
└── README.md             # This file
```

---

## 🧹 Cleanup

```bash
# Delete Kubernetes deployment
kubectl delete namespace jenkins-app

# Remove Docker images
docker rmi jenkins-discord-app:latest

# Stop Jenkins
docker stop jenkins
docker rm jenkins
```

---

## 🎓 What You'll Learn

- ✅ Docker containerization
- ✅ Kubernetes deployments
- ✅ Jenkins CI/CD pipelines
- ✅ GitHub webhooks integration
- ✅ Secret management
- ✅ Infrastructure as Code

---

## 📚 Next Steps

Once this works, you can:
1. Add automated tests
2. Implement health checks
3. Set up monitoring (Prometheus/Grafana)
4. Deploy to cloud Kubernetes (AWS EKS, GKE, AKS)
5. Add multiple environments (dev/staging/prod)

---

## 🆘 Need Help?

- Check Jenkins console logs
- View pod logs: `kubectl logs -l app=jenkins-discord-app -n jenkins-app`
- Verify Discord webhook in browser
- Check GitHub webhook delivery status

---

## 📝 License

MIT License - Feel free to use and modify!

---

**Happy Learning! 🚀**
