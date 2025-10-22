Terraform for a single-VM WordPress site on GCP

This example provisions a single Compute Engine VM (Debian) and installs a LAMP stack + WordPress via a startup script.

Overview
- VPC, subnet and firewall
- Static external IP
- Compute Engine VM (Debian 11)
- Startup script installs Apache, MariaDB, PHP and WordPress

Security & caveats
- This is a simple demo. For production, use Cloud SQL for managed DB, Cloud CDN, HTTPS (managed certs), backups, monitoring, and hardened OS images.
- You must provide a non-default `db_password` and secure your GCP credentials.

Quickstart
1. Authenticate with Google Cloud (gcloud or service account JSON):

```bash
# Preferred: use gcloud auth
gcloud auth application-default login
# or export a service account key
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/key.json"
```

Credentials note
- Terraform requires Application Default Credentials (ADC). If you get a "could not find default credentials" error, run the `gcloud auth application-default login` command or set `GOOGLE_APPLICATION_CREDENTIALS` to a service account JSON key with sufficient IAM rights (compute.networkAdmin, compute.admin, serviceusage.serviceUsageAdmin, iam.serviceAccountUser, etc.).

2. Initialize and apply:

```bash
cd terraform
terraform init
terraform plan -var="project=your-project-id" \
  -var="db_password=your-db-password" \
  -var="region=us-central1" -var="zone=us-central1-a"

terraform apply -var="project=your-project-id" \
  -var="db_password=your-db-password" -auto-approve
```

3. After apply, terraform will output the external IP. Open it in your browser and finish the WordPress web installer.

Notes
- The terraform config attempts to enable the Compute and Storage APIs. You may need project-level permissions to enable services.
- For production, migrate the DB to Cloud SQL and use HTTPS certificates.
