resource "google_compute_network" "primary" {
  name                    = "primary"
  auto_create_subnetworks = true
}
