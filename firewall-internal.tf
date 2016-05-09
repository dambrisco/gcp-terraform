resource "google_compute_firewall" "internal" {
  name    = "${replace("${var.prefix}-${google_compute_network.primary.name}-allow-internal", "/^-/", "")}"
  network = "${google_compute_network.primary.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
  }

  source_ranges = [
    "${google_compute_subnetwork.primary.*.ip_cidr_range}",
    "${formatlist("%s/32", compact(split(",", var.whitelisted-ips)))}"
  ]
  source_tags   = ["bastion"]
}
