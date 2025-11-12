# Agent Starter Pack: Complete Deployment Guide for AI Agents

## Purpose

This manual teaches AI agents how to use the **Google Cloud Agent Starter Pack** - a production-ready framework that generates complete agent projects with code, infrastructure, CI/CD, and monitoring in minutes.

**What you'll learn**:
- Create production agents in 5 minutes
- Choose the right template for your use case
- Deploy to Cloud Run or Agent Engine
- Setup automated CI/CD pipelines
- Monitor and scale in production

**Repository**: https://github.com/GoogleCloudPlatform/agent-starter-pack

---

## Quick Start (5 Minutes)

```bash
# Install (no installation needed with uvx!)
uvx agent-starter-pack create my-agent

# Interactive prompts will ask:
# - Agent template: adk_base, agentic_rag, langgraph_base_react, etc.
# - Deployment target: cloud_run or agent_engine
# - CI/CD runner: github_actions or google_cloud_build

# Navigate to project
cd my-agent

# Install dependencies
make install

# Run locally
make playground

# Open browser to http://localhost:8501
```

**That's it!** You now have a complete agent with:
- ✅ Agent code with tools
- ✅ Testing framework
- ✅ Local development environment
- ✅ Deployment infrastructure (Terraform)
- ✅ CI/CD pipeline templates
- ✅ Makefile with standard commands

---

## Understanding the Starter Pack

### What It Creates

```
my-agent/
├── app/                        # Your agent code
│   ├── agent.py               # Agent definition
│   ├── tools.py               # Tool implementations
│   ├── retrievers.py          # RAG components (if RAG template)
│   ├── fast_api_app.py        # Cloud Run app
│   └── agent_engine_app.py    # Agent Engine app
├── deployment/
│   └── terraform/             # Infrastructure as Code
│       ├── dev/               # Development environment
│       └── main/              # Staging/Production
├── tests/
│   ├── unit/                  # Fast, mocked tests
│   ├── integration/           # Real GCP tests
│   └── load_test/             # Performance tests
├── data_ingestion/            # RAG data pipeline (if RAG template)
│   └── submit_pipeline.py
├── notebooks/                 # Jupyter notebooks for experimentation
├── .github/workflows/         # CI/CD (GitHub Actions)
│   ├── pr_checks.yaml
│   ├── staging.yaml
│   └── deploy-to-prod.yaml
├── Makefile                   # Standard commands
├── pyproject.toml            # Python dependencies
├── README.md                  # Project documentation
└── GEMINI.md                  # AI assistant guidance
```

### What It Does NOT Create

- ❌ Your specific business logic (you add this)
- ❌ Your custom tools (you implement these)
- ❌ Your data (you provide this for RAG)
- ❌ GCP project (you create this separately)

**Think of it as**: A fully-equipped kitchen where you bring the ingredients (your data, logic, tools) and cook your specific recipe (your agent).

---

## Choosing the Right Template

### Template Comparison

| Template | Pattern | Best For | Complexity |
|----------|---------|----------|------------|
| **adk_base** | ReAct | General chatbots, simple automation | Low |
| **adk_a2a_base** | Distributed ReAct | Multi-domain coordination | Medium |
| **agentic_rag** | RAG | Document Q&A, knowledge systems | Medium |
| **langgraph_base_react** | Graph-based | Complex workflows, state management | Medium |
| **crewai_coding_crew** | Multi-agent crew | Code generation + review | High |
| **adk_live** | Real-time multimodal | Voice/video agents | High |

### Decision Tree

```
Do you need document/knowledge search?
├─ YES → agentic_rag
└─ NO
    ├─ Need voice/video?
    │   └─ YES → adk_live
    └─ NO
        ├─ Need multiple specialized agents?
        │   ├─ YES (collaboration) → crewai_coding_crew
        │   ├─ YES (distributed) → adk_a2a_base
        │   └─ NO → Continue
        └─ Need complex workflows?
            ├─ YES → langgraph_base_react
            └─ NO → adk_base (start here!)
```

### Template Details

#### adk_base (Recommended for beginners)

**What you get**:
- Single ReAct agent
- 2 sample tools (weather, time)
- Streamlit UI
- Full deployment setup

**Example use cases**:
- Customer support chatbot
- Task automation agent
- General Q&A assistant

**Create**:
```bash
uvx agent-starter-pack create support-bot \
  --agent adk_base \
  --deployment-target cloud_run
```

#### agentic_rag (Recommended for knowledge systems)

**What you get**:
- RAG agent with retrieval tool
- Data ingestion pipeline
- Vertex AI Search or Vector Search
- Document processing
- Full deployment setup

**Example use cases**:
- Documentation assistant
- Legal/medical knowledge systems
- Enterprise search chatbot

**Create**:
```bash
uvx agent-starter-pack create doc-assistant \
  --agent agentic_rag \
  --deployment-target agent_engine \
  --include-data-ingestion \
  --datastore vertex_ai_search
```

#### adk_a2a_base (For distributed systems)

**What you get**:
- A2A Protocol support
- Agent card exposure
- JSON-RPC 2.0 communication
- Multi-agent coordination
- A2A Inspector tool

**Example use cases**:
- Cross-department coordination
- Distributed agent networks
- Framework-agnostic agent systems

**Create**:
```bash
uvx agent-starter-pack create distributed-agent \
  --agent adk_a2a_base \
  --deployment-target cloud_run
```

#### langgraph_base_react (For complex workflows)

**What you get**:
- LangGraph state machine
- Explicit workflow control
- State persistence
- Streaming support

**Example use cases**:
- Multi-step approval workflows
- Complex decision trees
- Stateful conversations

**Create**:
```bash
uvx agent-starter-pack create workflow-agent \
  --agent langgraph_base_react \
  --deployment-target agent_engine
```

#### crewai_coding_crew (For collaborative agents)

**What you get**:
- Multiple specialized agents
- LangGraph orchestrator
- CrewAI team coordination
- Sequential task execution

**Example use cases**:
- Code generation + review
- Content creation + editing
- Research + synthesis

**Create**:
```bash
uvx agent-starter-pack create coding-crew \
  --agent crewai_coding_crew \
  --deployment-target cloud_run
```

#### adk_live (For multimodal real-time)

**What you get**:
- Gemini Multimodal Live API
- React frontend
- WebSocket communication
- Audio/video/text support
- FastAPI backend

**Example use cases**:
- Voice assistants
- Video analysis agents
- Real-time conversations

**Create**:
```bash
uvx agent-starter-pack create voice-agent \
  --agent adk_live \
  --deployment-target agent_engine
```

---

## Deployment Targets

### Cloud Run vs Agent Engine

| Feature | Cloud Run | Agent Engine |
|---------|-----------|--------------|
| **Execution Model** | Container-based | LLM-native |
| **Setup Complexity** | Medium (Docker) | Low (managed) |
| **Flexibility** | High (full control) | Medium (constrained) |
| **Scaling** | Auto-scale (0-1000s) | Auto-scale (managed) |
| **Cold Start** | 5-30 seconds | <5 seconds |
| **Session Management** | Custom (Redis, AlloyDB) | Built-in |
| **Pricing** | Pay per request | Pay per query |
| **Best For** | Custom backends, HTTP APIs | LLM agents, simple deployments |

### When to Choose Cloud Run

**Choose Cloud Run if you need**:
- Custom web frameworks (FastAPI, Flask)
- Non-Python code (Node.js, Go)
- External service integrations
- Full container control
- Websockets or long-running connections
- A2A Protocol support

**Example deployment**:
```bash
# Create with Cloud Run target
uvx agent-starter-pack create my-agent \
  --agent adk_base \
  --deployment-target cloud_run

cd my-agent

# Deploy
make deploy
```

**What happens**:
1. Builds Docker container
2. Pushes to Artifact Registry
3. Deploys to Cloud Run
4. Configures service account
5. Sets environment variables
6. Returns public URL

### When to Choose Agent Engine

**Choose Agent Engine if you need**:
- Managed agent hosting
- No infrastructure management
- Built-in session persistence
- Simple LLM-based agents
- Quick deployments

**Example deployment**:
```bash
# Create with Agent Engine target
uvx agent-starter-pack create my-agent \
  --agent adk_base \
  --deployment-target agent_engine

cd my-agent

# Deploy
make deploy
```

**What happens**:
1. Packages agent code
2. Uploads to Vertex AI
3. Creates Reasoning Engine
4. Returns resource name
5. Agent ready to query

---

## Step-by-Step Deployment

### Scenario 1: Simple Chatbot (Cloud Run)

**Goal**: Deploy a customer support chatbot to Cloud Run

```bash
# 1. Create project
uvx agent-starter-pack create support-bot \
  --agent adk_base \
  --deployment-target cloud_run \
  --cicd-runner github_actions \
  --region us-central1

# 2. Navigate
cd support-bot

# 3. Customize agent
# Edit app/agent.py:
```

```python
# app/agent.py
from google.adk.agents import Agent

def check_order_status(order_id: str) -> str:
    """Check order status."""
    # Your logic here
    return f"Order {order_id}: Shipped"

def create_ticket(issue: str) -> str:
    """Create support ticket."""
    # Your logic here
    return f"Ticket #{12345} created"

instruction = """You are a customer support agent for Acme Corp.
Help users with:
- Order status
- Returns and refunds
- Technical issues
- Account management

Be friendly and professional."""

agent = Agent(
    name="support_agent",
    model="gemini-2.5-flash",
    instruction=instruction,
    tools=[check_order_status, create_ticket],
)
```

```bash
# 4. Test locally
make install
make playground

# 5. Run tests
make test

# 6. Setup infrastructure
export PROJECT_ID="your-gcp-project"
make setup-dev-env

# 7. Deploy to dev
make deploy

# 8. Test deployed agent
curl https://support-bot-xxx-uc.a.run.app/query \
  -H "Content-Type: application/json" \
  -d '{"query": "Where is order #12345?"}'

# 9. Setup CI/CD
uvx agent-starter-pack setup-cicd

# 10. Push to GitHub
git remote add origin https://github.com/user/support-bot.git
git push -u origin main
```

### Scenario 2: Document Assistant (Agent Engine + RAG)

**Goal**: Deploy a documentation Q&A agent with RAG

```bash
# 1. Create project with RAG
uvx agent-starter-pack create doc-assistant \
  --agent agentic_rag \
  --deployment-target agent_engine \
  --include-data-ingestion \
  --datastore vertex_ai_search \
  --region us-central1

# 2. Navigate
cd doc-assistant

# 3. Add your documents
cp ~/my-docs/*.pdf data_ingestion/sample_data/

# 4. Setup infrastructure (creates datastore)
export PROJECT_ID="your-gcp-project"
make setup-dev-env

# 5. Ingest documents
make data-ingestion

# This runs:
# - Vertex AI Pipeline
# - Chunking (512 tokens, 100 overlap)
# - Embedding generation
# - Upload to Vertex AI Search

# 6. Customize agent instruction
# Edit app/agent.py:
```

```python
# app/agent.py
instruction = """You are a documentation assistant for Acme Corp.

Answer questions using the knowledge base. Always cite sources.

If you don't find relevant information, say "I don't have information about that in the documentation."
"""

# Agent is already configured with retrieve_docs tool
```

```bash
# 7. Test locally
make install
make playground

# Try queries like:
# - "How do I deploy an agent?"
# - "What are the pricing options?"

# 8. Deploy to Agent Engine
make deploy

# 9. Query deployed agent
```

```python
from google.cloud import aiplatform

agent = aiplatform.ReasoningEngine(
    "projects/PROJECT_ID/locations/us-central1/reasoningEngines/AGENT_ID"
)

response = agent.query(input="How do I configure authentication?")
print(response["output"])
```

### Scenario 3: Multi-Agent System (A2A)

**Goal**: Deploy coordinated agents across domains

```bash
# 1. Create engineering agent
uvx agent-starter-pack create engineering-agent \
  --agent adk_a2a_base \
  --deployment-target cloud_run

cd engineering-agent
make setup-dev-env
make deploy
# Note the URL: https://engineering-agent-xxx.run.app

# 2. Create sales agent
cd ..
uvx agent-starter-pack create sales-agent \
  --agent adk_a2a_base \
  --deployment-target cloud_run

cd sales-agent
make setup-dev-env
make deploy
# Note the URL: https://sales-agent-xxx.run.app

# 3. Configure peer coordination
# In engineering-agent/app/agent.py:
```

```python
import os

PEER_AGENTS = {
    "sales": os.getenv("SALES_AGENT_URL", ""),
    "operations": os.getenv("OPS_AGENT_URL", ""),
}

def coordinate_with_peer(domain: str, request: str) -> str:
    """Coordinate with peer agent via A2A Protocol."""
    from a2a_sdk import A2AClient

    peer_url = PEER_AGENTS.get(domain)
    if not peer_url:
        return f"Peer '{domain}' not configured"

    client = A2AClient(base_url=peer_url)
    task = client.tasks.create(messages=[{
        "role": "user",
        "content": [{"type": "text", "text": request}]
    }])

    task = client.tasks.wait_until_complete(task.id, timeout=30)
    return task.artifacts[0].parts[0].text

agent = Agent(
    name="engineering_agent",
    model="gemini-2.0-flash",
    instruction="You coordinate with sales and operations teams.",
    tools=[coordinate_with_peer],
)
```

```bash
# 4. Deploy with peer URLs
cd engineering-agent
make deploy SALES_AGENT_URL=https://sales-agent-xxx.run.app

# 5. Test coordination
curl https://engineering-agent-xxx.run.app/query \
  -d '{"query": "Get sales forecast from sales team"}'

# Engineering agent → calls sales agent → returns consolidated result
```

---

## CI/CD Setup

### Automated CI/CD with One Command

```bash
# From inside your project
uvx agent-starter-pack setup-cicd
```

**What this does**:
1. Creates staging and production GCP projects
2. Connects GitHub repository
3. Sets up service accounts
4. Configures secrets
5. Deploys Terraform infrastructure
6. Creates CI/CD workflows

**Result**: Fully automated pipeline

```
Pull Request → Run tests
    ↓
Merge to main → Deploy to staging → Run load tests
    ↓
Manual approval → Deploy to production
```

### Manual CI/CD Setup (GitHub Actions)

**1. Create GitHub secrets**:
```bash
# In GitHub repo → Settings → Secrets
GCP_PROJECT_ID_STAGING=your-staging-project
GCP_PROJECT_ID_PROD=your-prod-project
GCP_SA_KEY=<service-account-json>
```

**2. Workflows are already created**:
```
.github/workflows/
├── pr_checks.yaml         # Run on pull requests
├── staging.yaml           # Deploy to staging on merge
└── deploy-to-prod.yaml    # Deploy to prod on manual trigger
```

**3. Push to GitHub**:
```bash
git remote add origin https://github.com/user/my-agent.git
git push -u origin main
```

**4. Workflows automatically trigger**:
- **PR created** → Runs tests
- **PR merged** → Deploys to staging
- **Production button clicked** → Deploys to prod

### CI/CD Pipeline Details

#### PR Checks (pr_checks.yaml)
```yaml
name: PR Checks
on: pull_request

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.11"
      - name: Install dependencies
        run: make install
      - name: Run tests
        run: make test
      - name: Run linting
        run: make lint
```

#### Staging Deployment (staging.yaml)
```yaml
name: Deploy to Staging
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      - name: Deploy to staging
        run: make deploy
        env:
          PROJECT_ID: ${{ secrets.GCP_PROJECT_ID_STAGING }}
      - name: Run load tests
        run: |
          uv run locust -f tests/load_test/locustfile.py \
            --headless --users 100 --spawn-rate 10 --run-time 5m
```

#### Production Deployment (deploy-to-prod.yaml)
```yaml
name: Deploy to Production
on: workflow_dispatch  # Manual trigger

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production  # Requires approval
    steps:
      - uses: actions/checkout@v3
      - name: Authenticate to Google Cloud
        uses: google-github-actions/auth@v1
        with:
          credentials_json: ${{ secrets.GCP_SA_KEY }}
      - name: Deploy to production
        run: make deploy
        env:
          PROJECT_ID: ${{ secrets.GCP_PROJECT_ID_PROD }}
```

---

## Infrastructure (Terraform)

### What Terraform Creates

**For all agents**:
- Service accounts with appropriate IAM roles
- Cloud Storage buckets (for logs, artifacts)
- BigQuery datasets (for analytics)
- Secret Manager secrets
- Log sinks (to BigQuery)

**For Cloud Run agents**:
- Cloud Run service
- Cloud Run IAM bindings
- Artifact Registry repository

**For Agent Engine agents**:
- Vertex AI resources
- Reasoning Engine configuration

**For RAG agents**:
- Vertex AI Search datastore
- Vertex AI Vector Search index (if using Vector Search)
- Cloud Storage bucket for documents

### Terraform Commands

```bash
# Navigate to Terraform directory
cd deployment/terraform/dev

# Initialize
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Destroy infrastructure
terraform destroy
```

### Customizing Infrastructure

Edit `deployment/terraform/dev/variables.tf`:

```hcl
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "cloud_run_memory" {
  description = "Memory allocation for Cloud Run"
  type        = string
  default     = "2Gi"
}

variable "cloud_run_cpu" {
  description = "CPU allocation for Cloud Run"
  type        = string
  default     = "2"
}

variable "min_instances" {
  description = "Minimum instances"
  type        = number
  default     = 0  # Scale to zero
}

variable "max_instances" {
  description = "Maximum instances"
  type        = number
  default     = 10
}
```

---

## Monitoring & Observability

### Built-in Monitoring

Every project includes:
- **Cloud Logging**: Real-time logs
- **Cloud Trace**: Distributed tracing
- **BigQuery**: Long-term analytics
- **OpenTelemetry**: Custom metrics

### Viewing Logs

```bash
# View logs
gcloud logging read "resource.type=cloud_run_revision" --limit 50

# Tail logs
gcloud logging tail "resource.type=cloud_run_revision"

# Filter logs
gcloud logging read "severity>=ERROR" --limit 10
```

### Custom Metrics

```python
# app/agent.py
import logging
from opentelemetry import trace

logger = logging.getLogger(__name__)
tracer = trace.get_tracer(__name__)

def handle_query(query: str) -> str:
    with tracer.start_as_current_span("agent_query") as span:
        span.set_attribute("query_length", len(query))

        logger.info("Processing query", extra={"query": query})

        response = agent.send_message(query)

        span.set_attribute("response_length", len(response))
        logger.info("Query completed", extra={"response_length": len(response)})

        return response
```

### Dashboard

Included Looker Studio template tracks:
- Request latency (p50, p95, p99)
- Error rates
- Request volume
- Tool usage
- User feedback scores

**Access**: Cloud Console → Looker Studio → Import template

---

## Production Best Practices

### 1. Environment Management

```bash
# Use separate projects for dev/staging/prod
export PROJECT_ID_DEV="my-agent-dev"
export PROJECT_ID_STAGING="my-agent-staging"
export PROJECT_ID_PROD="my-agent-prod"

# Deploy to each
gcloud config set project $PROJECT_ID_DEV
make deploy

gcloud config set project $PROJECT_ID_STAGING
make deploy

gcloud config set project $PROJECT_ID_PROD
make deploy
```

### 2. Secret Management

```bash
# Store secrets in Secret Manager
gcloud secrets create API_KEY --data-file=- <<< "your-api-key"

# Reference in code
import os
api_key = os.getenv("API_KEY")  # Auto-loaded from Secret Manager
```

### 3. Rate Limiting

```python
# app/tools.py
import time
from collections import deque

class RateLimiter:
    def __init__(self, rpm: int = 60):
        self.requests = deque()
        self.limit = rpm

    def acquire(self):
        now = time.time()
        while self.requests and self.requests[0] < now - 60:
            self.requests.popleft()

        if len(self.requests) >= self.limit:
            sleep_time = 60 - (now - self.requests[0])
            time.sleep(sleep_time)

        self.requests.append(now)

limiter = RateLimiter(rpm=60)

def call_external_api(query: str) -> str:
    limiter.acquire()
    return requests.get(f"https://api.example.com?q={query}").text
```

### 4. Cost Optimization

```python
# Use appropriate model for task
def route_query(query: str) -> str:
    if is_simple(query):
        model = "gemini-2.0-flash"  # Cheaper
    else:
        model = "gemini-2.5-pro"    # Better quality

    agent = Agent(model=model, ...)
    return agent.send_message(query)

# Cache common contexts
from vertexai.preview.caching import CachedContent

cached = CachedContent.create(
    model_name="gemini-2.5-flash",
    contents=[large_documentation],
    ttl="3600s",
)

agent = Agent.from_cached_content(cached)
```

### 5. Testing Strategy

```bash
# Run all tests before deployment
make test

# Unit tests (fast, mocked)
uv run pytest tests/unit -v

# Integration tests (real GCP)
uv run pytest tests/integration -v

# Load tests (performance)
uv run locust -f tests/load_test/locustfile.py \
  --headless --users 100 --run-time 5m
```

---

## Troubleshooting

### Issue: "make deploy" fails

**Error**: `gcloud: command not found`

**Solution**:
```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash
exec -l $SHELL
gcloud init
```

**Error**: `Permission denied`

**Solution**:
```bash
# Authenticate
gcloud auth application-default login

# Set project
gcloud config set project YOUR_PROJECT_ID
```

**Error**: `API not enabled`

**Solution**:
```bash
# Enable required APIs
gcloud services enable \
  aiplatform.googleapis.com \
  run.googleapis.com \
  artifactregistry.googleapis.com
```

### Issue: Agent not responding

**Symptom**: 500 errors or timeouts

**Debug**:
```bash
# Check logs
gcloud logging read "resource.type=cloud_run_revision" --limit 50

# Check service status
gcloud run services describe my-agent --region us-central1

# Test locally
make playground
# Try same query locally
```

**Common causes**:
1. **Missing environment variables**: Check `gcloud run services describe`
2. **Timeout**: Increase timeout in `deployment/terraform/main/cloud_run.tf`
3. **Memory**: Increase memory allocation
4. **Permissions**: Check service account IAM roles

### Issue: High costs

**Symptom**: Unexpected high bills

**Debug**:
```bash
# Check model usage
gcloud logging read "jsonPayload.model_name!=null" --limit 100

# Check request volume
gcloud monitoring time-series list \
  --filter='metric.type="run.googleapis.com/request_count"'
```

**Solutions**:
1. Use cheaper models (gemini-2.0-flash instead of gemini-2.5-pro)
2. Implement caching
3. Add rate limiting
4. Set max_instances in Terraform

### Issue: RAG returns no results

**Symptom**: Agent says "I don't have information about that"

**Debug**:
```bash
# Check if datastore has documents
gcloud alpha search datastores describe DATASTORE_ID

# Re-run data ingestion
make data-ingestion

# Test retrieval directly
```

```python
from google.cloud import discoveryengine_v1

client = discoveryengine_v1.SearchServiceClient()
response = client.search(...)
print(response)  # Check if results returned
```

**Solutions**:
1. **Wait for indexing**: Can take 5-15 minutes after ingestion
2. **Check document format**: Ensure PDFs/text files are valid
3. **Verify datastore ID**: Check `app/retrievers.py` has correct ID
4. **Adjust query**: Try simpler, more direct queries

---

## Advanced Topics

### Remote Templates

Use custom or community templates:

```bash
# From GitHub
uvx agent-starter-pack create my-agent \
  --agent https://github.com/user/custom-template

# From local path
uvx agent-starter-pack create my-agent \
  --agent local@./my-template

# ADK samples shortcut
uvx agent-starter-pack create my-agent \
  --agent adk@gemini-fullstack
```

### Enhancing Existing Agents

Add starter pack infrastructure to existing projects:

```bash
cd my-existing-agent
uvx agent-starter-pack enhance

# Adds:
# - Terraform infrastructure
# - CI/CD pipelines
# - Testing framework
# - Makefile
# - Notebooks
```

### Gemini Enterprise Integration

Register agent to Gemini Enterprise:

```bash
# After deployment
AGENT_ENGINE_ID="projects/.../reasoningEngines/..." \
  make register-gemini-enterprise

# Agent now available enterprise-wide
```

---

## Summary

### Quick Command Reference

| Task | Command |
|------|---------|
| Create project | `uvx agent-starter-pack create PROJECT_NAME` |
| Install deps | `make install` |
| Run locally | `make playground` |
| Run tests | `make test` |
| Lint code | `make lint` |
| Setup infra | `make setup-dev-env` |
| Deploy | `make deploy` |
| Setup CI/CD | `uvx agent-starter-pack setup-cicd` |
| Ingest data (RAG) | `make data-ingestion` |
| View logs | `gcloud logging tail` |

### Templates Quick Reference

- **adk_base**: Start here for most agents
- **agentic_rag**: Need document search
- **adk_live**: Need voice/video
- **adk_a2a_base**: Need distributed agents
- **langgraph_base_react**: Need complex workflows
- **crewai_coding_crew**: Need agent collaboration

### Deployment Quick Reference

- **Cloud Run**: Custom backends, full control
- **Agent Engine**: Simple agents, managed hosting

### Next Steps

1. **Create first agent**: `uvx agent-starter-pack create my-agent`
2. **Customize**: Edit `app/agent.py`, add tools
3. **Test**: `make playground`, `make test`
4. **Deploy**: `make setup-dev-env`, `make deploy`
5. **CI/CD**: `uvx agent-starter-pack setup-cicd`
6. **Monitor**: View logs, traces, analytics

**Resources**:
- Documentation: https://googlecloudplatform.github.io/agent-starter-pack/
- Repository: https://github.com/GoogleCloudPlatform/agent-starter-pack
- Issues: https://github.com/GoogleCloudPlatform/agent-starter-pack/issues

**Zero to production in 5 minutes with full CI/CD, monitoring, and best practices built-in.**
