terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    # Configure via:
    # terraform init -backend-config="bucket=YOUR_BUCKET"
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Local variables
locals {
  agent_sa_name = "${var.agent_name}-sa"
  agent_sa_email = "${local.agent_sa_name}@${var.project_id}.iam.gserviceaccount.com"

  common_labels = {
    environment = var.environment
    agent       = var.agent_name
    managed_by  = "terraform"
  }
}

# Enable required APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "aiplatform.googleapis.com",            # Vertex AI
    "discoveryengine.googleapis.com",       # Vertex AI Search
    "firestore.googleapis.com",             # Firestore
    "storage-api.googleapis.com",           # Cloud Storage
    "secretmanager.googleapis.com",         # Secret Manager
    "logging.googleapis.com",               # Cloud Logging
    "monitoring.googleapis.com",            # Cloud Monitoring
    "cloudtrace.googleapis.com",            # Cloud Trace
    "bigquery.googleapis.com",              # BigQuery
  ])

  service            = each.key
  disable_on_destroy = false
}

# Service account for the agent
resource "google_service_account" "agent_sa" {
  account_id   = local.agent_sa_name
  display_name = "Supreme Commander Agent Service Account"
  description  = "Service account used by Supreme Commander Agent for GCP operations"
}

# IAM roles for the service account
resource "google_project_iam_member" "agent_roles" {
  for_each = toset([
    "roles/aiplatform.user",              # Vertex AI operations
    "roles/discoveryengine.editor",       # Vertex AI Search
    "roles/datastore.user",               # Firestore
    "roles/storage.objectAdmin",          # Cloud Storage
    "roles/secretmanager.secretAccessor", # Read secrets
    "roles/logging.logWriter",            # Write logs
    "roles/cloudtrace.agent",             # Tracing
    "roles/monitoring.metricWriter",      # Metrics
    "roles/bigquery.dataEditor",          # BigQuery
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.agent_sa.email}"

  depends_on = [google_service_account.agent_sa]
}

# Secrets for Slack integration
resource "google_secret_manager_secret" "slack_bot_token" {
  secret_id = var.slack_bot_token_secret

  labels = local.common_labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret" "slack_signing_secret" {
  secret_id = var.slack_signing_secret_secret

  labels = local.common_labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

resource "google_secret_manager_secret" "slack_app_token" {
  secret_id = var.slack_app_token_secret

  labels = local.common_labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

# Grant service account access to secrets
resource "google_secret_manager_secret_iam_member" "slack_secrets_access" {
  for_each = toset([
    google_secret_manager_secret.slack_bot_token.id,
    google_secret_manager_secret.slack_signing_secret.id,
    google_secret_manager_secret.slack_app_token.id,
  ])

  secret_id = each.key
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.agent_sa.email}"

  depends_on = [google_service_account.agent_sa]
}

# Cloud Storage bucket for agent data
resource "google_storage_bucket" "agent_data" {
  name          = "${var.project_id}-${var.agent_name}-data"
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  labels = local.common_labels

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  depends_on = [google_project_service.required_apis]
}

# Grant service account access to bucket
resource "google_storage_bucket_iam_member" "agent_bucket_access" {
  bucket = google_storage_bucket.agent_data.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.agent_sa.email}"

  depends_on = [google_service_account.agent_sa]
}

# BigQuery dataset for analytics and logging
resource "google_bigquery_dataset" "agent_analytics" {
  dataset_id    = "${replace(var.agent_name, "-", "_")}_analytics"
  friendly_name = "Supreme Commander Analytics"
  description   = "Analytics and logging data for Supreme Commander Agent"
  location      = var.region

  labels = local.common_labels

  default_table_expiration_ms = 7776000000 # 90 days

  depends_on = [google_project_service.required_apis]
}

# BigQuery table for task logs
resource "google_bigquery_table" "task_logs" {
  dataset_id = google_bigquery_dataset.agent_analytics.dataset_id
  table_id   = "task_logs"

  schema = jsonencode([
    {
      name = "timestamp"
      type = "TIMESTAMP"
      mode = "REQUIRED"
    },
    {
      name = "task_id"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "agent_id"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "status"
      type = "STRING"
      mode = "REQUIRED"
    },
    {
      name = "priority"
      type = "STRING"
      mode = "NULLABLE"
    },
    {
      name = "description"
      type = "STRING"
      mode = "NULLABLE"
    },
  ])

  time_partitioning {
    type = "DAY"
  }

  depends_on = [google_bigquery_dataset.agent_analytics]
}

# Log sink to BigQuery
resource "google_logging_project_sink" "agent_logs_to_bigquery" {
  count = var.enable_monitoring ? 1 : 0

  name        = "${var.agent_name}-logs-to-bigquery"
  description = "Export Supreme Commander logs to BigQuery"

  destination = "bigquery.googleapis.com/projects/${var.project_id}/datasets/${google_bigquery_dataset.agent_analytics.dataset_id}"

  filter = "resource.labels.service_name=\"${var.agent_name}\""

  bigquery_options {
    use_partitioned_tables = true
  }

  depends_on = [
    google_bigquery_dataset.agent_analytics,
    google_project_service.required_apis,
  ]
}

# Grant BigQuery data editor role to logging service account
resource "google_project_iam_member" "log_sink_bigquery_access" {
  count = var.enable_monitoring ? 1 : 0

  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = google_logging_project_sink.agent_logs_to_bigquery[0].writer_identity

  depends_on = [google_logging_project_sink.agent_logs_to_bigquery]
}

# Vertex AI Search datastore (optional)
resource "google_discovery_engine_data_store" "knowledge_base" {
  count = var.enable_vertex_ai_search ? 1 : 0

  location                    = "global"
  data_store_id               = var.data_store_id
  display_name                = "Supreme Commander Knowledge Base"
  industry_vertical           = "GENERIC"
  solution_types              = ["SOLUTION_TYPE_SEARCH"]
  create_advanced_site_search = false

  depends_on = [google_project_service.required_apis]
}
