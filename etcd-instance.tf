module "etcd-coreos-user-data" {
  source   = "git::https://github.com/brandfolder/terraform-coreos-user-data.git?ref=master"
  etcd2_discovery = "${var.etcd_discovery_url}"
  etcd2_advertise-client-urls = "http://var!private_ipv4:2379,http://var!private_ipv4:4001"
  etcd2_initial-advertise-peer-urls = "http://var!private_ipv4:2380,http://var!private_ipv4:7001"
  etcd2_listen-client-urls = "http://0.0.0.0:2379,http://0.0.0.0:4001"
  etcd2_listen-peer-urls = "http://var!private_ipv4:2380,http://var!private_ipv4:7001"
  flannel_interface = "var!private_ipv4"
  fleet_metadata = "role=etcd"
  fleet_public_ip = "var!private_ipv4"
  fleet_engine_reconcile_interval = "10"
  fleet_etcd_request_timeout = "5.0"
  fleet_agent_ttl = "120s"
}

resource "google_compute_instance" "etcd" {
  count        = "${var.etcd-count}"
  name         = "etcd-${count.index}"
  machine_type = "${var.etcd-instance-type}"
  zone         = "${var.zone}"

  tags = ["etcd"]

  disk {
    image = "${var.etcd-image}"
  }

  // Local SSD disk
  disk {
    type    = "local-ssd"
    scratch = true
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    user-data = "${module.etcd-coreos-user-data.user-data}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
