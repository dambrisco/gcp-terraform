module "bastion-coreos-user-data" {
  source                          = "git::https://github.com/brandfolder/terraform-coreos-user-data.git?ref=master"
  etcd2_discovery                 = "${var.etcd_discovery_url}"
  etcd2_listen-client-urls        = "http://0.0.0.0:2379,http://0.0.0.0:4001"
  etcd2_proxy                     = "on"
  flannel_interface               = "var!private_ipv4"
  fleet_metadata                  = "role=bastion"
  fleet_public_ip                 = "var!private_ipv4"
  fleet_engine_reconcile_interval = "10"
  fleet_etcd_request_timeout      = "5.0"
  fleet_agent_ttl                 = "120s"
}

resource "google_compute_instance" "bastion" {
  name        = "bastion"
  description = "Bastion host"
  zone        = "${element(split(",", var.zones), 1)}"

  tags = ["bastion"]

  machine_type = "${var.bastion-instance-type}"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    type        = "pd-ssd"
    auto_delete = true
    size        = 50
    image       = "${var.bastion-image}"
  }

  network_interface {
    subnetwork = "${element(google_compute_subnetwork.primary.*.name, 1)}"
  }

  metadata {
    user-data = "${module.bastion-coreos-user-data.user-data}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
