output "instance_name" {
  value = google_compute_instance.wp_vm.name
}

output "wordpress_ip" {
  value = google_compute_address.wp_ip.address
}
output "wordpress_url" {
  value = "http://${google_compute_address.wp_ip.address}/"
}