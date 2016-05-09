resource "template_file" "bastion-write_files" {
  template = "${file("config/write_files/bastion.yml")}"
}

resource "template_file" "bastion-units" {
  template = "${file("config/units/bastion.yml")}"
}

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
  write_files                     = "${template_file.bastion-write_files.rendered}"
  units                           = "${template_file.bastion-units.rendered}"
}

resource "google_compute_instance" "bastion" {
  name        = "${join("-", replace("${var.prefix}-bastion", "/^-/", ""))}"
  description = "Bastion host"
  zone        = "${element(split(",", var.zones), 0)}"

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
    subnetwork = "${element(google_compute_subnetwork.primary.*.name, 0)}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    user-data = "${module.bastion-coreos-user-data.user-data}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
