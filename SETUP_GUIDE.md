# 🚀 QUICK SETUP GUIDE

Follow these steps in order:

## ✅ Step 1: Install Prerequisites (15 mins)

### Docker Desktop
1. Download from: https://www.docker.com/products/docker-desktop
2. Install and start
3. Go to Settings → Kubernetes
4. ✅ Check "Enable Kubernetes"
5. Click "Apply & Restart"
6. Wait 2-5 minutes

**Verify:**
```bash
docker --version
kubectl version --client
```

---

## ✅ Step 2: Install Jenkins (5 mins)

```bash
# Create network
docker network create jenkins

# Run Jenkins
docker run -d \
  --name jenkins \
  --network jenkins \
  -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.kube:/root/.kube \
  jenkins/jenkins:lts

# Get password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

**Open:** http://localhost:8080
- Paste password
- Install suggested plugins
- Create admin user

---

## ✅ Step 3: Configure Jenkins (10 mins)

### Install Plugins
**Manage Jenkins → Plugins → Available**
Search and install:
- Git Plugin
- GitHub Plugin
- Pipeline Plugin
- Docker Pipeline Plugin
- Kubernetes CLI Plugin

### Install kubectl in Jenkins
```bash
docker exec -it jenkins bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
kubectl version --client
exit
```

### Fix Docker permissions
```bash
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

---

## ✅ Step 4: Get Discord Webhook (2 mins)

1. Open Discord (or create free account)
2. Create a server (click + button)
3. Right-click server name → Server Settings
4. Go to Integrations → Webhooks
5. Click "New Webhook"
6. Name it "Jenkins Bot"
7. Select a channel (e.g., #general)
8. **Copy Webhook URL** (looks like: https://discord.com/api/webhooks/...)

---

## ✅ Step 5: Add Secrets to Jenkins (3 mins)

### Add Discord Webhook
**Manage Jenkins → Credentials → (global) → Add Credentials**
- Kind: Secret text
- Secret: [Paste Discord webhook URL]
- ID: `discord-webhook`
- Description: Discord Webhook
- Click Create

### Create GitHub Token
1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Name: `Jenkins-Token`
4. Scopes: ✅ repo, ✅ admin:repo_hook
5. Generate and **COPY THE TOKEN**

### Add GitHub Token to Jenkins
**Manage Jenkins → Credentials → Add Credentials**
- Kind: Username with password
- Username: [Your GitHub username]
- Password: [Paste GitHub token]
- ID: `github-credentials`
- Description: GitHub Token
- Click Create

---

## ✅ Step 6: Prepare Your Code (5 mins)

### Option A: Clone this repo
```bash
git clone https://github.com/YOUR_USERNAME/jenkins-k8s-project.git
cd jenkins-k8s-project
```

### Option B: Use provided files
1. Extract the ZIP file
2. Open terminal in the folder

### Create .env for local testing (optional)
```bash
cp .env.example .env
# Edit .env and paste your Discord webhook URL
```

---

## ✅ Step 7: Push to GitHub (3 mins)

```bash
# Initialize git (if new repo)
git init
git add .
git commit -m "Initial commit: Jenkins K8s pipeline"

# Create repo on GitHub.com
# Then add remote:
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push
git push -u origin main
```

---

## ✅ Step 8: Create Jenkins Job (5 mins)

**Jenkins → New Item**
- Name: `kubernetes-deployment-pipeline`
- Type: Pipeline
- Click OK

**Configure:**
1. **General:**
   - ✅ GitHub project
   - URL: `https://github.com/YOUR_USERNAME/YOUR_REPO`

2. **Build Triggers:**
   - ✅ GitHub hook trigger for GITScm polling

3. **Pipeline:**
   - Definition: Pipeline script from SCM
   - SCM: Git
   - Repository URL: `https://github.com/YOUR_USERNAME/YOUR_REPO.git`
   - Credentials: `github-credentials`
   - Branch: `*/main`
   - Script Path: `Jenkinsfile`

4. Click **Save**

---

## ✅ Step 9: Configure GitHub Webhook (3 mins)

**GitHub → Your Repo → Settings → Webhooks → Add webhook**
- Payload URL: `http://YOUR_IP_ADDRESS:8080/github-webhook/`
  - Find your IP: Run `ipconfig` (Windows) or `ifconfig` (Mac/Linux)
  - Example: `http://192.168.1.100:8080/github-webhook/`
- Content type: `application/json`
- Which events: Just the push event
- ✅ Active
- Click Add webhook

---

## ✅ Step 10: Test! (2 mins)

### Test 1: Manual Build
1. Go to Jenkins → Your pipeline
2. Click "Build Now"
3. Watch the build stages
4. Check Discord for notification! 🎉

### Test 2: Auto-Trigger
```bash
# Make a change
echo "# Test auto-deployment" >> README.md

# Commit and push
git add .
git commit -m "Test auto-trigger"
git push origin main
```

Jenkins should automatically start building!

---

## ✅ Step 11: Verify Deployment

```bash
# Check pods
kubectl get pods -n jenkins-app

# View logs
kubectl logs -l app=jenkins-discord-app -n jenkins-app

# Check all resources
kubectl get all -n jenkins-app
```

---

## 🎉 Success Checklist

- [ ] Docker Desktop installed ✅
- [ ] Kubernetes enabled ✅
- [ ] Jenkins running on localhost:8080 ✅
- [ ] kubectl works in Jenkins ✅
- [ ] Discord webhook created ✅
- [ ] GitHub token created ✅
- [ ] Secrets added to Jenkins ✅
- [ ] Code pushed to GitHub ✅
- [ ] Jenkins pipeline created ✅
- [ ] GitHub webhook configured ✅
- [ ] Manual build successful ✅
- [ ] Auto-trigger works ✅
- [ ] Discord notification received ✅

---

## 🆘 Common Issues

### Jenkins can't connect to GitHub
```bash
# Verify credentials in Jenkins
# Re-generate GitHub token with correct scopes
```

### kubectl not found
```bash
docker exec -it jenkins bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/
exit
```

### Docker permission denied
```bash
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

### Pods not starting
```bash
# Check pod status
kubectl describe pod -l app=jenkins-discord-app -n jenkins-app

# View events
kubectl get events -n jenkins-app
```

### Discord notification not sent
- Verify webhook URL is correct
- Check if secret was created: `kubectl get secret -n jenkins-app`
- View pod logs: `kubectl logs -l app=jenkins-discord-app -n jenkins-app`

---

## 📞 Get Help

If stuck:
1. Check Jenkins console output
2. View build logs
3. Check pod logs: `kubectl logs -l app=jenkins-discord-app -n jenkins-app`
4. Verify webhook delivery in GitHub → Settings → Webhooks

---

**Total Setup Time: ~50 minutes**

Good luck! 🚀
