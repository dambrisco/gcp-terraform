resource "template_file" "k8s-worker-write_files" {
  template = "${file("config/write_files/k8s-worker.yml")}"
}

resource "template_file" "k8s-worker-units" {
  template = "${file("config/units/k8s-worker.yml")}"
}

module "k8s-worker-coreos-user-data" {
  source                          = "git::https://github.com/brandfolder/terraform-coreos-user-data.git?ref=master"
  etcd2_discovery                 = "${var.etcd_discovery_url}"
  etcd2_listen-client-urls        = "http://0.0.0.0:2379,http://0.0.0.0:4001"
  etcd2_proxy                     = "on"
  flannel_interface               = "var!private_ipv4"
  fleet_metadata                  = "role=kubernetes,type=worker,web=true"
  fleet_public_ip                 = "var!private_ipv4"
  fleet_engine_reconcile_interval = "10"
  fleet_etcd_request_timeout      = "5.0"
  fleet_agent_ttl                 = "120s"
  write_files                     = "${template_file.k8s-worker-write_files.rendered}"
  units                           = "${template_file.k8s-worker-units.rendered}"
}

resource "google_compute_instance" "k8s-worker" {
  count       = "${var.worker-count}"
  name        = "${replace("${var.prefix}-k8s-worker-${count.index}", "/^-/", "")}"
  description = "Kubernetes worker"
  zone        = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"

  tags = ["kubernetes", "worker", "web"]

  machine_type = "${coalesce(var.worker-instance-type, var.default-instance-type)}"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    type        = "pd-ssd"
    auto_delete = true
    size        = 100
    image       = "${coalesce(var.worker-image, var.default-image)}"
  }

  network_interface {
    subnetwork = "${element(google_compute_subnetwork.primary.*.name, count.index % length(split(",", var.zones)))}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    user-data = "${module.k8s-worker-coreos-user-data.user-data}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
