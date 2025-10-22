provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

# Enable common APIs (terraform will try to enable them if not already enabled)
resource "google_project_service" "compute_api" {
  service = "compute.googleapis.com"
  project = var.project
}
resource "google_project_service" "sql_api" {
  service = "sqladmin.googleapis.com"
  project = var.project
}
resource "google_project_service" "storage_api" {
  service = "storage.googleapis.com"
  project = var.project
}
provider "local" {
  # ei välttämätön, local provider on mukana Terraformissa useimmissa ympäristöissä
}

resource "local_file" "ansible_inventory" {
  content = <<EOF
[wordpress]
${google_compute_address.wp_ip.address} ansible_user=tjarvenpaa ansible_ssh_private_key_file=/home/ci/.ssh/wp_gcp
EOF
  filename = "${path.module}/../ansible/inventory.ini"
}