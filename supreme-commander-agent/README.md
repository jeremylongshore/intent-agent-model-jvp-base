# Supreme Commander Agent

> **The boss of all boss agents** - A multi-agent orchestration system for goal alignment and task organization.

## Overview

Supreme Commander is a sophisticated AI agent designed to orchestrate complex multi-agent systems. It serves as the highest-level coordinator, focusing on:

- **Goal Alignment**: Ensuring all agent activities serve strategic objectives
- **Task Organization**: Breaking down complex goals into actionable tasks
- **Agent Coordination**: Delegating to specialist agents and coordinating between peers
- **Strategic Decision-Making**: Making high-level decisions about approach and methodology
- **Communication**: Real-time updates via Slack and Firebase dashboard

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│              Supreme Commander Agent                     │
│                                                          │
│  ┌─────────────┐  ┌──────────────┐  ┌───────────────┐ │
│  │ Goal        │  │ Task         │  │ Agent         │ │
│  │ Alignment   │  │ Organization │  │ Coordination  │ │
│  └─────────────┘  └──────────────┘  └───────────────┘ │
│                                                          │
│  ┌─────────────────────────────────────────────────┐   │
│  │         RAG Knowledge Grounding                  │   │
│  │         (Vertex AI Search)                       │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   ┌────▼────┐       ┌────▼────┐       ┌────▼────┐
   │ Slack   │       │ Firebase │       │ Specialist│
   │Interface│       │Dashboard │       │  Agents  │
   └─────────┘       └─────────┘       └──────────┘
```

## Features

### ✅ Multi-Agent Orchestration
- Delegate tasks to specialist agents
- Coordinate between peer agents
- Track task execution and progress
- Handle escalations and conflicts

### ✅ Knowledge Grounding
- Vertex AI Search integration for RAG
- Document-based decision making
- Citation and source tracking

### ✅ Real-Time Communication
- **Slack Integration**: Direct messaging, commands, mentions
- **Firebase Dashboard**: Real-time metrics and status updates
- **Proactive Notifications**: Alerts for critical events

### ✅ Production-Ready Deployment
- Vertex AI Agent Engine (serverless)
- Automated CI/CD with GitHub Actions
- Infrastructure as Code (Terraform)
- Comprehensive monitoring and logging

## Quick Start

### Prerequisites

- Python 3.10+
- Google Cloud Platform project
- Firebase project
- Slack workspace (optional)

### 1. Install Dependencies

```bash
make install
```

### 2. Configure GCP

```bash
# Set project
export PROJECT_ID="your-gcp-project"
gcloud config set project $PROJECT_ID

# Authenticate
gcloud auth application-default login
```

### 3. Setup Infrastructure

```bash
# Provision all required GCP resources
make setup-infra
```

This creates:
- Vertex AI Agent Engine resources
- Vertex AI Search datastore
- Firestore database
- BigQuery analytics dataset
- Secret Manager secrets
- Service accounts and IAM roles

### 4. Configure Secrets

```bash
# Store Slack tokens in Secret Manager
echo "xoxb-your-bot-token" | gcloud secrets versions add slack-bot-token --data-file=-
echo "your-signing-secret" | gcloud secrets versions add slack-signing-secret --data-file=-
echo "xapp-your-app-token" | gcloud secrets versions add slack-app-token --data-file=-
```

### 5. Deploy Agent

```bash
# Deploy to Vertex AI Agent Engine
make deploy
```

### 6. Query Agent

```python
from google.cloud import aiplatform

# Initialize
aiplatform.init(project="your-project", location="us-central1")

# Get agent
agent = aiplatform.ReasoningEngine("projects/PROJECT_ID/locations/REGION/reasoningEngines/AGENT_ID")

# Query
response = agent.query(input="Deploy the new authentication system")
print(response["output"])
```

## Communication Interfaces

### Slack

Interact with Supreme Commander via Slack:

**Direct Message**:
```
@SupremeCommander Deploy the new feature to staging
```

**Slash Command**:
```
/supreme Create a plan for the Q4 product launch
```

**Mentions**:
```
Hey @SupremeCommander what's the status of task #12345?
```

### Firebase Dashboard

Real-time dashboard showing:
- Active goals and tasks
- Agent utilization metrics
- System health
- Recent alerts

Access at: `https://your-project.firebaseapp.com`

## Development

### Running Tests

```bash
# Unit tests
make test

# Integration tests (requires GCP credentials)
make test-integration

# All tests with coverage
pytest tests/ -v --cov=app
```

### Code Quality

```bash
# Run all checks
make lint

# Auto-format code
make format
```

### Local Development

```bash
# Run Slack interface locally
make run-slack
```

## Deployment

### Staging Deployment

Push to `main` branch triggers automatic deployment to staging:

```bash
git push origin main
```

### Production Deployment

Manual deployment with approval:

1. Go to GitHub Actions
2. Select "Deploy to Production" workflow
3. Click "Run workflow"
4. Type "DEPLOY" to confirm
5. Wait for approval (if required)

Or via Make:

```bash
make deploy-prod
# Type 'DEPLOY' when prompted
```

## Configuration

### Environment Variables

```bash
# Required
export PROJECT_ID="your-gcp-project"
export FIREBASE_DATABASE_URL="https://your-project.firebaseio.com"

# Optional
export DATA_STORE_ID="supreme-commander-knowledge"
export DATA_STORE_REGION="global"
export SUPREME_COMMANDER_MODEL="gemini-2.5-flash"
```

### Secrets (Google Secret Manager)

- `slack-bot-token`: Slack bot OAuth token
- `slack-signing-secret`: Slack request signing secret
- `slack-app-token`: Slack app-level token (for Socket Mode)

### GitHub Secrets

Configure in repository settings:

**Development**:
- `GCP_PROJECT_ID_DEV`
- `GCP_SA_KEY_DEV`

**Staging**:
- `GCP_PROJECT_ID_STAGING`
- `GCP_SA_KEY_STAGING`

**Production**:
- `GCP_PROJECT_ID_PROD`
- `GCP_SA_KEY_PROD`

**Slack** (all environments):
- `SLACK_BOT_TOKEN`
- `SLACK_SIGNING_SECRET`
- `SLACK_APP_TOKEN`
- `SLACK_WEBHOOK_URL`

## Architecture Decisions

### Why Vertex AI Agent Engine?

- **Serverless**: No Docker, no infrastructure management
- **Managed**: Auto-scaling, monitoring, built-in session management
- **Cost-effective**: Pay only for queries
- **Integration**: Native Vertex AI and Google Cloud services

### Why RAG (Vertex AI Search)?

- **Grounded responses**: Decisions based on documented knowledge
- **Citations**: Traceable to source documents
- **Up-to-date**: Knowledge base updates without retraining

### Why Slack + Firebase?

- **Slack**: Where teams already communicate
- **Firebase**: Real-time dashboard for executive visibility
- **Dual interface**: Conversational + visual

## Tools & Capabilities

The Supreme Commander has access to these tools:

| Tool | Purpose |
|------|---------|
| `retrieve_knowledge` | Search knowledge base for relevant information |
| `create_task_plan` | Create structured execution plans |
| `track_goal_progress` | Monitor task and goal status |
| `delegate_to_agent` | Assign tasks to specialist agents |
| `coordinate_with_peer_agent` | Request from peer agents |
| `send_slack_notification` | Send updates to Slack |
| `update_firebase_dashboard` | Update real-time metrics |

## Monitoring & Observability

### Logs

```bash
# View agent logs
make logs

# Or via gcloud
gcloud logging read "resource.type=aiplatform.googleapis.com/ReasoningEngine" --limit=100
```

### Metrics

All metrics stored in BigQuery:
- Task completion rates
- Agent utilization
- Response times
- Error rates

Query example:
```sql
SELECT
  timestamp,
  task_id,
  agent_id,
  status,
  priority
FROM `project.supreme_commander_analytics.task_logs`
WHERE DATE(timestamp) = CURRENT_DATE()
ORDER BY timestamp DESC
LIMIT 100
```

### Traces

Distributed tracing with OpenTelemetry:
```bash
# View traces in Cloud Console
https://console.cloud.google.com/traces
```

## Troubleshooting

### Agent not responding

```bash
# Check agent status
gcloud ai reasoning-engines describe AGENT_ID --region=us-central1

# View recent errors
make logs | grep ERROR
```

### Slack integration not working

```bash
# Verify secrets
gcloud secrets versions access latest --secret=slack-bot-token

# Check Slack interface logs
docker logs supreme-commander-slack
```

### Deployment failed

```bash
# Check GitHub Actions logs
# Go to: github.com/YOUR_REPO/actions

# Or check local deployment
make deploy 2>&1 | tee deploy.log
```

## Project Structure

```
supreme-commander-agent/
├── app/
│   ├── agent.py                    # Supreme Commander agent
│   ├── tools.py                    # Agent tools
│   ├── retrievers.py               # RAG knowledge retrieval
│   ├── slack_interface.py          # Slack integration
│   ├── firebase_interface.py       # Firebase dashboard
│   └── agent_engine_app.py         # Vertex AI Agent Engine entry point
├── deployment/
│   └── terraform/                  # Infrastructure as Code
├── tests/
│   ├── unit/                       # Unit tests
│   └── integration/                # Integration tests
├── .github/
│   └── workflows/                  # CI/CD pipelines
├── Makefile                        # Development commands
├── pyproject.toml                  # Python dependencies
└── README.md                       # This file
```

## Contributing

1. Create feature branch: `git checkout -b feature/amazing-feature`
2. Make changes and test: `make test && make lint`
3. Commit: `git commit -m 'Add amazing feature'`
4. Push: `git push origin feature/amazing-feature`
5. Create Pull Request

## License

[Your License Here]

## Support

For issues and questions:
- GitHub Issues: [Your Repo URL]
- Documentation: [Your Docs URL]
- Slack: #supreme-commander

---

**Built with**:
- Google Cloud Vertex AI
- Google ADK
- Firebase
- Slack Bolt
- Terraform
- GitHub Actions
