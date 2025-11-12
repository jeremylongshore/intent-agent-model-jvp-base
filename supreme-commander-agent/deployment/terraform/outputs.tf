# Terraform outputs for Supreme Commander Agent

output "service_account_email" {
  description = "Email of the agent service account"
  value       = google_service_account.agent_sa.email
}

output "data_bucket_name" {
  description = "Name of the Cloud Storage bucket for agent data"
  value       = google_storage_bucket.agent_data.name
}

output "bigquery_dataset_id" {
  description = "BigQuery dataset ID for analytics"
  value       = google_bigquery_dataset.agent_analytics.dataset_id
}

output "data_store_id" {
  description = "Vertex AI Search datastore ID"
  value       = var.enable_vertex_ai_search ? google_discovery_engine_data_store.knowledge_base[0].data_store_id : "not_created"
}

output "slack_bot_token_secret_name" {
  description = "Secret Manager name for Slack bot token"
  value       = google_secret_manager_secret.slack_bot_token.secret_id
}

output "slack_signing_secret_name" {
  description = "Secret Manager name for Slack signing secret"
  value       = google_secret_manager_secret.slack_signing_secret.secret_id
}

output "slack_app_token_secret_name" {
  description = "Secret Manager name for Slack app token"
  value       = google_secret_manager_secret.slack_app_token.secret_id
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    service_account = google_service_account.agent_sa.email
    data_bucket     = google_storage_bucket.agent_data.name
    bigquery_dataset = google_bigquery_dataset.agent_analytics.dataset_id
    datastore_enabled = var.enable_vertex_ai_search
    monitoring_enabled = var.enable_monitoring
  }
}
