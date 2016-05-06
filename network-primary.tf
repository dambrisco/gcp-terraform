resource "google_compute_network" "primary" {
  name       = "primary"
  ipv4_range = "10.0.0.0/16"
}
