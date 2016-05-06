resource "template_file" "etcd-write_files" {
  template = "${file("config/write_files/etcd.yml")}"
}

resource "template_file" "etcd-units" {
  template = "${file("config/units/etcd.yml")}"
}

module "etcd-coreos-user-data" {
  source                            = "git::https://github.com/brandfolder/terraform-coreos-user-data.git?ref=master"
  etcd2_discovery                   = "${var.etcd_discovery_url}"
  etcd2_advertise-client-urls       = "http://var!public_ipv4:2379,http://var!public_ipv4:4001"
  etcd2_initial-advertise-peer-urls = "http://var!public_ipv4:2380,http://var!public_ipv4:7001"
  etcd2_listen-client-urls          = "http://0.0.0.0:2379,http://0.0.0.0:4001"
  etcd2_listen-peer-urls            = "http://var!public_ipv4:2380,http://var!public_ipv4:7001"
  etcd2_debug                       = true
  flannel_interface                 = "var!public_ipv4"
  fleet_metadata                    = "role=etcd"
  fleet_public_ip                   = "var!public_ipv4"
  fleet_engine_reconcile_interval   = "10"
  fleet_etcd_request_timeout        = "5.0"
  fleet_agent_ttl                   = "120s"
  write_files                       = "${template_file.etcd-write_files.rendered}"
  units                             = "${template_file.etcd-units.rendered}"
}

resource "google_compute_disk" "etcd" {
  count = "${var.etcd-count}"
  name  = "etcd-${count.index}"
  zone  = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"
  image = "${var.etcd-image}"
  type  = "pd-ssd"
  size  = 100
}

resource "google_compute_address" "etcd" {
  count  = "${var.etcd-count}"
  name   = "etcd-${count.index}"
  region = "${replace(element(split(",", var.zones), count.index % length(split(",", var.zones))), "/-[a-z]$/", "")}"
}

resource "google_compute_instance" "etcd" {
  count        = "${var.etcd-count}"
  name         = "etcd-${count.index}"
  description  = "Etcd master"
  machine_type = "${var.etcd-instance-type}"
  zone         = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"

  tags = ["etcd"]

  disk {
    disk        = "${element(google_compute_disk.etcd.*.name, count.index)}"
    auto_delete = false
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  network_interface {
    subnetwork = "${element(google_compute_subnetwork.primary.*.name, count.index % length(split(",", var.zones)))}"

    access_config {
      nat_ip = "${element(google_compute_address.etcd.*.address, count.index)}"
    }
  }

  metadata {
    user-data = "${module.etcd-coreos-user-data.user-data}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
