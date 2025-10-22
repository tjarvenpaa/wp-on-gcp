# WordPress on Google Cloud — Terraform README (layout)

## Overview
Short description of this repository: Terraform code to provision a WordPress site on Google Cloud Platform (Compute Engine + optional Cloud SQL, firewall, static IP, and startup script).

## Prerequisites
- Google Cloud project with billing enabled
- gcloud SDK installed and authenticated
- Terraform installed (v1.x recommended)
- Service account key JSON (or Workload Identity) with required IAM roles:
    - roles/compute.admin, roles/iam.serviceAccountUser, roles/sql.admin (if using Cloud SQL), roles/storage.admin (optional)
- APIs enabled: compute.googleapis.com, sqladmin.googleapis.com, iam.googleapis.com, cloudresourcemanager.googleapis.com

## Repository layout
- main.tf — provider, resources, modules
- variables.tf — input variables with descriptions and defaults
- outputs.tf — useful outputs (site_ip, sql_instance_name, etc.)
- terraform.tfvars.example — example values for terraform.tfvars
- scripts/startup.sh — startup script to install WordPress/PHP/Apache or connect to Cloud SQL
- modules/ — optional modular components (network, compute, sql)

## Configuration (variables)
List important variables to set in terraform.tfvars or via CLI:
- project: GCP project id
- region: e.g. us-central1
- zone: e.g. us-central1-a
- machine_type: e.g. e2-medium
- wordpress_instance_name
- wordpress_db_password (or use Secret Manager)
- use_cloud_sql: true/false
- static_ip: true/false

## Provider example
Brief provider snippet (in main.tf):
```hcl
provider "google" {
    project = var.project
    region  = var.region
    zone    = var.zone
}
```

## Quick start (commands)
1. Authenticate (if using service account JSON):
     - export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
2. Initialize:
     - terraform init
3. Validate & plan:
     - terraform validate
     - terraform plan -var-file="terraform.tfvars"
4. Apply:
     - terraform apply -var-file="terraform.tfvars"
5. After apply: get site IP or URL from outputs:
     - terraform output site_ip
6. Destroy when done:
     - terraform destroy -var-file="terraform.tfvars"

## Accessing WordPress
- If static IP assigned: visit http://<site_ip> or configure DNS
- If using Cloud SQL: ensure startup script configures wp-config.php to use Cloud SQL connection

## Security & best practices
- Do not store secrets in plain terraform.tfvars; use Secret Manager or environment variables
- Use Cloud SQL (managed DB) for production
- Use HTTPS: provision a load balancer with managed SSL or use certbot on VM (better: LB)
- Harden firewall: only allow HTTP/HTTPS and SSH from trusted sources
- Use instance templates + managed instance group for scaling

## Troubleshooting
- Check VM serial console and startup script logs: gcloud compute instances get-serial-port-output
- Check Cloud SQL logs in GCP Console if DB connection fails
- Ensure service account has necessary IAM roles and APIs are enabled

## Useful references
- Terraform Google provider docs
- GCP Cloud SQL and Compute Engine docs
- WordPress installation guide (for configuration details)

## Notes
- Example startup.sh should idempotently install PHP/Apache, fetch WordPress, set permissions and configure wp-config.php
- Consider modules to separate network, compute, and database concerns

Place this file at /home/tjarvenpaa/wp-on-gcp/readme.md and update variables.tf and terraform.tfvars.example with your project-specific values before running the commands above.