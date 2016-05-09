resource "google_compute_network" "primary" {
  name = "primary"
}

resource "google_compute_subnetwork" "primary" {
  count         = "${length(split(",", var.zones))}"
  name          = "primary-us-${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
  ip_cidr_range = "10.0.${count.index}.0/24"
  network       = "${google_compute_network.primary.self_link}"
  region        = "${replace(element(split(",", var.zones), count.index % length(split(",", var.zones))), "/-[a-z]$/", "")}"
}
