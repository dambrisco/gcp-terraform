module "k8s-worker-coreos-user-data" {
  source                          = "git::https://github.com/brandfolder/terraform-coreos-user-data.git?ref=master"
  etcd2_discovery                 = "${var.etcd_discovery_url}"
  etcd2_listen-client-urls        = "http://0.0.0.0:2379,http://0.0.0.0:4001"
  etcd2_proxy                     = "on"
  flannel_interface               = "var!private_ipv4"
  fleet_metadata                  = "role=k8s-worker"
  fleet_public_ip                 = "var!private_ipv4"
  fleet_engine_reconcile_interval = "10"
  fleet_etcd_request_timeout      = "5.0"
  fleet_agent_ttl                 = "120s"
}

resource "google_compute_instance" "k8s-worker" {
  count       = "${var.worker-count}"
  name        = "k8s-worker-${count.index}"
  description = "Kubernetes Worker"
  zone        = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"

  tags = ["kubernetes", "worker", "web"]

  description  = "Kubernetes worker"
  machine_type = "${var.worker-instance-type}"

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    type        = "pd-ssd"
    auto_delete = true
    image       = "${var.worker-image}"
  }

  network_interface {
    subnetwork = "${element(google_compute_subnetwork.primary.*.name, count.index % length(split(",", var.zones)))}"
  }

  metadata {
    user-data = "${module.k8s-worker-coreos-user-data.user-data}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}
