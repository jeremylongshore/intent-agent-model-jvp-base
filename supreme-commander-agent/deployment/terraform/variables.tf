# Terraform variables for Supreme Commander Agent deployment

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "agent_name" {
  description = "Name of the agent"
  type        = string
  default     = "supreme-commander"
}

variable "data_store_id" {
  description = "Vertex AI Search datastore ID for knowledge base"
  type        = string
  default     = "supreme-commander-knowledge"
}

variable "slack_bot_token_secret" {
  description = "Secret Manager name for Slack bot token"
  type        = string
  default     = "slack-bot-token"
}

variable "slack_signing_secret_secret" {
  description = "Secret Manager name for Slack signing secret"
  type        = string
  default     = "slack-signing-secret"
}

variable "slack_app_token_secret" {
  description = "Secret Manager name for Slack app token"
  type        = string
  default     = "slack-app-token"
}

variable "firebase_database_url" {
  description = "Firebase Realtime Database URL"
  type        = string
}

variable "enable_vertex_ai_search" {
  description = "Enable Vertex AI Search datastore creation"
  type        = bool
  default     = true
}

variable "enable_monitoring" {
  description = "Enable Cloud Monitoring and logging"
  type        = bool
  default     = true
}
