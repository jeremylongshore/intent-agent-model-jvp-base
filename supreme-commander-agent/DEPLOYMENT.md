# Supreme Commander - Deployment Guide

Complete guide for deploying the Supreme Commander Agent to production.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Infrastructure Provisioning](#infrastructure-provisioning)
4. [Secret Configuration](#secret-configuration)
5. [Agent Deployment](#agent-deployment)
6. [Slack Integration](#slack-integration)
7. [Firebase Dashboard](#firebase-dashboard)
8. [CI/CD Setup](#cicd-setup)
9. [Monitoring & Operations](#monitoring--operations)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts
- ✅ Google Cloud Platform account with billing enabled
- ✅ Firebase project
- ✅ Slack workspace (admin access)
- ✅ GitHub account

### Required Tools
```bash
# Install gcloud CLI
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init

# Install Terraform
brew install terraform  # macOS
# or
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Install uv (Python package manager)
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Required Permissions
Your GCP user needs these roles:
- Project Editor
- Vertex AI Admin
- Firebase Admin
- Secret Manager Admin

---

## Initial Setup

### 1. Create GCP Projects

Create separate projects for each environment:

```bash
# Development
gcloud projects create supreme-commander-dev --name="Supreme Commander Dev"

# Staging
gcloud projects create supreme-commander-staging --name="Supreme Commander Staging"

# Production
gcloud projects create supreme-commander-prod --name="Supreme Commander Prod"

# Set billing for each
for project in supreme-commander-dev supreme-commander-staging supreme-commander-prod; do
    gcloud beta billing projects link $project --billing-account=YOUR_BILLING_ACCOUNT_ID
done
```

### 2. Enable APIs

```bash
# Set project (repeat for each environment)
export PROJECT_ID="supreme-commander-dev"
gcloud config set project $PROJECT_ID

# Enable required APIs
gcloud services enable \
    aiplatform.googleapis.com \
    discoveryengine.googleapis.com \
    firestore.googleapis.com \
    storage-api.googleapis.com \
    secretmanager.googleapis.com \
    logging.googleapis.com \
    monitoring.googleapis.com \
    cloudtrace.googleapis.com \
    bigquery.googleapis.com
```

### 3. Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Select existing GCP project (e.g., `supreme-commander-prod`)
4. Enable Google Analytics (optional)
5. Create project

### 4. Setup Firestore

```bash
# Create Firestore database
gcloud firestore databases create --region=us-central1

# Create indexes (optional, for performance)
gcloud firestore indexes composite create \
    --collection-group=tasks \
    --field-config=field-path=status,order=ASCENDING \
    --field-config=field-path=created_at,order=DESCENDING
```

### 5. Setup Firebase Realtime Database

1. Go to Firebase Console → Realtime Database
2. Click "Create Database"
3. Choose location (us-central1)
4. Start in **locked mode** (we'll configure rules later)

**Security Rules** (update after creating):
```json
{
  "rules": {
    "dashboard": {
      ".read": "auth != null",
      ".write": "auth != null"
    },
    "metrics": {
      ".read": true,
      ".write": "auth != null"
    },
    "alerts": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

---

## Infrastructure Provisioning

### 1. Configure Terraform Backend

```bash
# Create bucket for Terraform state
gsutil mb -p $PROJECT_ID -l us-central1 gs://${PROJECT_ID}-terraform-state

# Enable versioning
gsutil versioning set on gs://${PROJECT_ID}-terraform-state
```

### 2. Create Terraform Variables

Create `deployment/terraform/terraform.tfvars`:

```hcl
project_id              = "supreme-commander-prod"
region                  = "us-central1"
environment             = "prod"
agent_name              = "supreme-commander"
data_store_id           = "supreme-commander-knowledge"
firebase_database_url   = "https://supreme-commander-prod.firebaseio.com"
enable_vertex_ai_search = true
enable_monitoring       = true
```

### 3. Initialize and Apply Terraform

```bash
cd deployment/terraform

# Initialize
terraform init -backend-config="bucket=${PROJECT_ID}-terraform-state"

# Plan
terraform plan -var-file=terraform.tfvars

# Apply
terraform apply -var-file=terraform.tfvars

# Save outputs
terraform output -json > terraform-outputs.json
```

**Expected Resources Created**:
- ✅ Service account (supreme-commander-sa)
- ✅ IAM roles and permissions
- ✅ Cloud Storage bucket
- ✅ BigQuery dataset and tables
- ✅ Vertex AI Search datastore
- ✅ Secret Manager secrets
- ✅ Log sinks to BigQuery

---

## Secret Configuration

### 1. Slack Secrets

**Get Slack Tokens**:
1. Go to https://api.slack.com/apps
2. Create new app → "From scratch"
3. Name: "Supreme Commander"
4. Select workspace

**Bot Token (xoxb-...)**:
1. OAuth & Permissions → Bot Token Scopes:
   - `chat:write`
   - `channels:history`
   - `channels:read`
   - `groups:history`
   - `im:history`
   - `mpim:history`
   - `commands`
2. Install to workspace
3. Copy "Bot User OAuth Token"

**App Token (xapp-...)**:
1. Basic Information → App-Level Tokens
2. Generate Token → Name: "Socket Mode", Scope: `connections:write`
3. Copy token

**Signing Secret**:
1. Basic Information → App Credentials → Signing Secret
2. Click "Show" and copy

**Store in Secret Manager**:
```bash
# Bot token
echo "xoxb-YOUR-TOKEN" | gcloud secrets versions add slack-bot-token --data-file=-

# Signing secret
echo "YOUR-SIGNING-SECRET" | gcloud secrets versions add slack-signing-secret --data-file=-

# App token
echo "xapp-YOUR-TOKEN" | gcloud secrets versions add slack-app-token --data-file=-
```

### 2. Verify Secrets

```bash
# List secrets
gcloud secrets list

# Access secret (to verify)
gcloud secrets versions access latest --secret=slack-bot-token
```

---

## Agent Deployment

### Method 1: Manual Deployment

```bash
# From project root
make install
make deploy
```

This will:
1. Package the agent code
2. Upload to Vertex AI
3. Create Reasoning Engine
4. Return agent resource name

**Save the resource name**:
```
projects/PROJECT_ID/locations/us-central1/reasoningEngines/AGENT_ID
```

### Method 2: GitHub Actions (Recommended)

#### Setup GitHub Secrets

In GitHub repository → Settings → Secrets:

```
GCP_PROJECT_ID_STAGING=supreme-commander-staging
GCP_PROJECT_ID_PROD=supreme-commander-prod

GCP_SA_KEY_STAGING=<service-account-json>
GCP_SA_KEY_PROD=<service-account-json>

SLACK_BOT_TOKEN=xoxb-...
SLACK_SIGNING_SECRET=...
SLACK_APP_TOKEN=xapp-...
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/...
```

**Get Service Account Keys**:
```bash
# Create keys for GitHub Actions
gcloud iam service-accounts keys create staging-key.json \
    --iam-account=supreme-commander-sa@supreme-commander-staging.iam.gserviceaccount.com

gcloud iam service-accounts keys create prod-key.json \
    --iam-account=supreme-commander-sa@supreme-commander-prod.iam.gserviceaccount.com

# Copy contents and add to GitHub Secrets
cat staging-key.json  # Copy to GCP_SA_KEY_STAGING
cat prod-key.json     # Copy to GCP_SA_KEY_PROD

# Delete local keys (security)
rm staging-key.json prod-key.json
```

#### Trigger Deployment

**Staging** (automatic on push to main):
```bash
git push origin main
```

**Production** (manual):
1. Go to GitHub → Actions
2. Select "Deploy to Production"
3. Click "Run workflow"
4. Type "DEPLOY" to confirm

### 3. Test Deployment

```python
from google.cloud import aiplatform

# Initialize
aiplatform.init(
    project="supreme-commander-prod",
    location="us-central1",
)

# Get agent
agent = aiplatform.ReasoningEngine(
    "projects/PROJECT_ID/locations/us-central1/reasoningEngines/AGENT_ID"
)

# Test query
response = agent.query(input="System check: Are you operational?")
print(response["output"])
```

Expected response:
```
Yes, I am operational. I'm the Supreme Commander, ready to orchestrate tasks and coordinate agents. How can I assist you?
```

---

## Slack Integration

### 1. Configure Slack App

**Event Subscriptions**:
1. Enable Event Subscriptions
2. Request URL: Will use Socket Mode (no URL needed)
3. Subscribe to bot events:
   - `message.channels`
   - `message.groups`
   - `message.im`
   - `message.mpim`
   - `app_mention`

**Slash Commands**:
1. Create command: `/supreme`
2. Request URL: (Socket Mode - not needed)
3. Short Description: "Interact with Supreme Commander"
4. Usage Hint: "Your request here"

**Socket Mode**:
1. Settings → Socket Mode → Enable
2. Use the app token created earlier

**Install App**:
1. Install App → Install to Workspace
2. Authorize

### 2. Run Slack Interface

**Option A: Cloud Run (Recommended)**

Create `Dockerfile.slack`:
```dockerfile
FROM python:3.11-slim

WORKDIR /app
COPY . .

RUN pip install -e .

CMD ["python", "-m", "app.slack_interface"]
```

Deploy:
```bash
gcloud run deploy supreme-commander-slack \
    --source . \
    --dockerfile Dockerfile.slack \
    --region us-central1 \
    --set-env-vars PROJECT_ID=$PROJECT_ID \
    --set-secrets SLACK_BOT_TOKEN=slack-bot-token:latest \
    --set-secrets SLACK_SIGNING_SECRET=slack-signing-secret:latest \
    --set-secrets SLACK_APP_TOKEN=slack-app-token:latest
```

**Option B: Local (Development)**

```bash
export PROJECT_ID="supreme-commander-dev"
export SLACK_BOT_TOKEN=$(gcloud secrets versions access latest --secret=slack-bot-token)
export SLACK_SIGNING_SECRET=$(gcloud secrets versions access latest --secret=slack-signing-secret)
export SLACK_APP_TOKEN=$(gcloud secrets versions access latest --secret=slack-app-token)

python -m app.slack_interface
```

### 3. Test Slack Integration

In Slack:
```
@SupremeCommander What are your capabilities?

/supreme Create a plan for deploying the authentication system

Message in a channel where the bot is added
```

---

## Firebase Dashboard

### 1. Deploy Dashboard

Create dashboard in `firebase-dashboard/`:

```bash
# Initialize Firebase Hosting
firebase init hosting

# Build dashboard (if using React/Vue)
cd firebase-dashboard
npm install
npm run build

# Deploy
firebase deploy --only hosting
```

### 2. Dashboard Features

The dashboard should display:

**Metrics** (from Realtime Database `/metrics`):
- Active tasks count
- Agent utilization
- Goal progress
- System health

**Alerts** (from `/alerts`):
- Critical alerts
- Task failures
- System errors

**Controls**:
- Query input
- Task creation
- Emergency stop

### 3. Sample Dashboard Code

```javascript
// firebase-dashboard/src/App.js
import { getDatabase, ref, onValue } from "firebase/database";

const db = getDatabase();

// Listen to metrics
const metricsRef = ref(db, 'metrics/task_status');
onValue(metricsRef, (snapshot) => {
  const data = snapshot.val();
  updateUI(data);
});

// Send query to agent
async function queryAgent(message) {
  const response = await fetch('AGENT_ENDPOINT', {
    method: 'POST',
    body: JSON.stringify({ input: message }),
  });
  return response.json();
}
```

---

## CI/CD Setup

### Workflow Overview

```
PR Created → Run Tests & Lint
    ↓
Merged to main → Deploy to Staging → Run Integration Tests
    ↓
Manual Trigger → Deploy to Production (with approval)
```

### Environment Protection

Configure in GitHub → Settings → Environments:

**Staging**:
- No protection rules (auto-deploy)

**Production**:
- Required reviewers: [Your team]
- Deployment branches: main only
- Wait timer: 5 minutes (optional)

### Monitoring Deployments

**GitHub Actions**:
- View all runs: github.com/YOUR_REPO/actions
- Deployment history per environment

**Slack Notifications**:
All deployments notify #deployments channel automatically

---

## Monitoring & Operations

### 1. View Logs

```bash
# Real-time logs
gcloud logging tail "resource.type=aiplatform.googleapis.com/ReasoningEngine"

# Errors only
gcloud logging read "severity>=ERROR AND resource.type=aiplatform.googleapis.com/ReasoningEngine" --limit=50

# Specific time range
gcloud logging read "resource.type=aiplatform.googleapis.com/ReasoningEngine" \
    --format="table(timestamp,severity,jsonPayload.message)" \
    --freshness=1h
```

### 2. Query Metrics

```sql
-- Task completion rate
SELECT
  DATE(timestamp) as date,
  COUNT(*) as total_tasks,
  COUNTIF(status = 'completed') as completed,
  COUNTIF(status = 'failed') as failed,
  ROUND(COUNTIF(status = 'completed') / COUNT(*) * 100, 2) as completion_rate
FROM `supreme_commander_analytics.task_logs`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY)
GROUP BY date
ORDER BY date DESC
```

### 3. Set Up Alerts

```bash
# Create alert policy for errors
gcloud alpha monitoring policies create \
    --notification-channels=CHANNEL_ID \
    --display-name="Supreme Commander Errors" \
    --condition-display-name="Error rate > 5%" \
    --condition-threshold-value=0.05 \
    --condition-threshold-duration=60s \
    --condition-filter='resource.type="aiplatform.googleapis.com/ReasoningEngine" AND severity="ERROR"'
```

### 4. Health Checks

Create Cloud Scheduler job for periodic health checks:

```bash
gcloud scheduler jobs create http supreme-commander-health-check \
    --schedule="*/15 * * * *" \
    --uri="https://AGENT_ENDPOINT/health" \
    --http-method=GET \
    --location=us-central1
```

---

## Troubleshooting

### Issue: Deployment Fails

**Symptom**: `make deploy` errors

**Debug**:
```bash
# Check authentication
gcloud auth list

# Check project
gcloud config get-value project

# Check API enabled
gcloud services list --enabled | grep aiplatform

# Enable if needed
gcloud services enable aiplatform.googleapis.com
```

### Issue: Agent Not Responding

**Symptom**: Queries time out or error

**Debug**:
```bash
# Check agent status
gcloud ai reasoning-engines describe AGENT_ID --region=us-central1

# Check logs
gcloud logging read "resource.type=aiplatform.googleapis.com/ReasoningEngine" --limit=20

# Test directly
python -c "
from google.cloud import aiplatform
agent = aiplatform.ReasoningEngine('AGENT_RESOURCE_NAME')
print(agent.query(input='test'))
"
```

### Issue: Slack Integration Not Working

**Symptom**: Bot doesn't respond in Slack

**Debug**:
```bash
# Check if Slack interface is running
gcloud run services describe supreme-commander-slack --region=us-central1

# Check secrets
gcloud secrets versions access latest --secret=slack-bot-token

# Check logs
gcloud logging read "resource.labels.service_name=supreme-commander-slack" --limit=20
```

**Common fixes**:
1. Verify Socket Mode is enabled
2. Check app token is valid
3. Ensure bot is added to channel
4. Verify OAuth scopes

### Issue: High Costs

**Symptom**: Unexpected GCP bill

**Debug**:
```bash
# Check current month costs
gcloud billing accounts list
gcloud beta billing projects describe $PROJECT_ID --format="value(billingAccountName)"

# Check Vertex AI usage
gcloud ai endpoints list --region=us-central1
```

**Cost optimization**:
1. Use gemini-2.0-flash (cheaper model)
2. Implement request caching
3. Set quotas on Vertex AI
4. Monitor with budget alerts

---

## Production Checklist

Before going live:

- [ ] All tests passing
- [ ] Infrastructure provisioned in production
- [ ] Secrets configured
- [ ] Agent deployed and tested
- [ ] Slack integration working
- [ ] Firebase dashboard deployed
- [ ] Monitoring and alerts configured
- [ ] Backup and disaster recovery plan
- [ ] Documentation updated
- [ ] Team trained on operations
- [ ] Incident response plan in place
- [ ] Cost monitoring configured
- [ ] Security review completed
- [ ] Load testing performed
- [ ] Rollback procedure tested

---

## Next Steps

After successful deployment:

1. **Monitor for 24 hours**: Watch logs and metrics
2. **Gather feedback**: From Slack users and dashboard
3. **Iterate**: Add new tools and capabilities
4. **Scale**: Add more specialist agents
5. **Optimize**: Reduce costs and improve performance
6. **Document**: Update runbooks and procedures

---

For questions or issues, contact [Your Team].
