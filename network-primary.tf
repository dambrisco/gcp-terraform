resource "google_compute_network" "primary" {
  name       = "primary"
}

resource "google_compute_subnetwork" "primary-us-east1" {
  name          = "primary-us-east1"
  ip_cidr_range = "10.0.0.0/16"
  network       = "${google_compute_network.primary.self_link}"
  region        = "${replace(var.zone, "/-[a-z]$/", "")}"
}
