variable "project" {
  description = "GCP project id"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "europe-north1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "europe-north1-a"
}

variable "machine_type" {
  description = "Compute instance machine type"
  type        = string
  default     = "e2-medium"
}

variable "instance_name" {
  description = "Name of the Compute Engine instance"
  type        = string
  default     = "wp-instance"
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "wp-vpc"
}

variable "db_user" {
  description = "WordPress DB username"
  type        = string
  default     = "wpuser"
}

variable "db_password" {
  description = "WordPress DB password (change this)"
  type        = string
  default     = "T399mqkbLeSj"  # NOTE: Change this default password in production
}

variable "site_title" {
  description = "WordPress site title"
  type        = string
  default     = "tjarvenpaa.Site"
}
