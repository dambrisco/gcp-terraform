resource "google_compute_firewall" "bastion" {
  name    = "${replace("${var.prefix}-${google_compute_network.primary.name}-allow-bastion-ssh", "/^-/", "")}"
  network = "${google_compute_network.primary.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["bastion"]
}
