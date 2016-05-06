provider "google" {
  region = "${element(var.zones, 0)}"
}
