resource "google_compute_firewall" "internal" {
  name    = "allow-internal"
  network = "${google_compute_network.primary.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = ["${google_compute_subnetwork.primary-us-east1.ip_cidr_range}"]
}
