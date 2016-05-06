resource "google_compute_firewall" "kubernetes" {
  name    = "allow-kubernetes"
  network = "${google_compute_network.primary.name}"

  allow {
    protocol = "tcp"
    ports    = ["443", "80", "2222", "9090"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["kubernetes"]
}
