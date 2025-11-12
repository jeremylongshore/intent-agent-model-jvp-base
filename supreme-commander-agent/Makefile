.PHONY: help install test lint deploy setup-infra clean

# Default target
help:
	@echo "Supreme Commander Agent - Makefile Commands"
	@echo ""
	@echo "Development:"
	@echo "  make install        Install dependencies"
	@echo "  make test           Run all tests"
	@echo "  make lint           Run code quality checks"
	@echo "  make format         Format code"
	@echo ""
	@echo "Deployment:"
	@echo "  make setup-infra    Provision infrastructure with Terraform"
	@echo "  make deploy         Deploy agent to Vertex AI Agent Engine"
	@echo "  make deploy-staging Deploy to staging environment"
	@echo "  make deploy-prod    Deploy to production environment"
	@echo ""
	@echo "Operations:"
	@echo "  make query          Query deployed agent (interactive)"
	@echo "  make logs           View agent logs"
	@echo "  make clean          Clean temporary files"

# Install dependencies
install:
	@echo "Installing dependencies..."
	@command -v uv >/dev/null 2>&1 || { echo "Installing uv..."; curl -LsSf https://astral.sh/uv/install.sh | sh; }
	uv pip install -e ".[dev]"
	@echo "✅ Dependencies installed"

# Run tests
test:
	@echo "Running tests..."
	pytest tests/unit -v --cov=app --cov-report=term-missing
	@echo "✅ Tests completed"

# Run integration tests
test-integration:
	@echo "Running integration tests (requires GCP credentials)..."
	pytest tests/integration -v
	@echo "✅ Integration tests completed"

# Lint code
lint:
	@echo "Running code quality checks..."
	ruff check app/ tests/
	ruff format --check app/ tests/
	mypy app/
	codespell app/ tests/ --skip="*.pyc,*.git"
	@echo "✅ Linting passed"

# Format code
format:
	@echo "Formatting code..."
	ruff format app/ tests/
	ruff check --fix app/ tests/
	@echo "✅ Code formatted"

# Setup infrastructure
setup-infra:
	@echo "Provisioning infrastructure with Terraform..."
	@cd deployment/terraform && \
		terraform init && \
		terraform plan -out=tfplan && \
		terraform apply tfplan
	@echo "✅ Infrastructure provisioned"

# Deploy to Vertex AI Agent Engine
deploy:
	@echo "Deploying Supreme Commander to Vertex AI Agent Engine..."
	@python -c "from scripts.deploy import deploy_agent; deploy_agent()"
	@echo "✅ Agent deployed"

# Deploy to staging
deploy-staging:
	@echo "Deploying to staging environment..."
	@PROJECT_ID=$(GCP_PROJECT_ID_STAGING) make deploy
	@echo "✅ Deployed to staging"

# Deploy to production
deploy-prod:
	@echo "⚠️  Deploying to PRODUCTION"
	@read -p "Type 'DEPLOY' to confirm: " confirm; \
	if [ "$$confirm" != "DEPLOY" ]; then \
		echo "❌ Deployment cancelled"; \
		exit 1; \
	fi
	@PROJECT_ID=$(GCP_PROJECT_ID_PROD) make deploy
	@echo "✅ Deployed to production"

# Query deployed agent
query:
	@echo "Querying Supreme Commander Agent..."
	@python -c "from scripts.query_agent import interactive_query; interactive_query()"

# View logs
logs:
	@echo "Fetching agent logs..."
	@gcloud logging read "resource.type=aiplatform.googleapis.com/Reasoning Engine" --limit=50

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".ruff_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	rm -f .coverage
	@echo "✅ Cleaned"

# Development server (for Slack interface)
run-slack:
	@echo "Starting Slack interface..."
	@python -m app.slack_interface

# Export environment variables from secrets
load-secrets:
	@echo "Loading secrets from Google Secret Manager..."
	@export SLACK_BOT_TOKEN=$$(gcloud secrets versions access latest --secret="slack-bot-token")
	@export SLACK_SIGNING_SECRET=$$(gcloud secrets versions access latest --secret="slack-signing-secret")
	@export SLACK_APP_TOKEN=$$(gcloud secrets versions access latest --secret="slack-app-token")
	@echo "✅ Secrets loaded"
