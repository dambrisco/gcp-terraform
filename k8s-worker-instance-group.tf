module "k8s-worker-coreos-user-data" {
  source   = "git::https://github.com/brandfolder/terraform-coreos-user-data.git?ref=master"
  etcd2_discovery = "${var.etcd_discovery_url}"
  etcd2_listen-client-urls = "http://0.0.0.0:2379,http://0.0.0.0:4001"
  etcd2_proxy = "on"
  flannel_interface = "var!private_ipv4"
  fleet_metadata = "role=k8s-worker"
  fleet_public_ip = "var!private_ipv4"
  fleet_engine_reconcile_interval = "10"
  fleet_etcd_request_timeout = "5.0"
  fleet_agent_ttl = "120s"
}

resource "google_compute_instance_template" "k8s-worker" {
  name        = "k8s-worker"
  description = "Kubernetes Worker"

  tags = ["kubernetes", "worker"]

  instance_description = "Kubernetes worker"
  machine_type         = "${var.worker-instance-type}"
  automatic_restart    = true
  on_host_maintenance  = "MIGRATE"

  disk {
    source_image = "${var.worker-image}"
  }

  network_interface {
    network = "default"
  }

  metadata {
    user-data = "${module.k8s-worker-coreos-user-data.user-data}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}

resource "google_compute_instance_group_manager" "k8s-worker" {
  name        = "k8s-worker"
  description = "Kubernetes Workers"

  base_instance_name = "k8s-worker"
  instance_template  = "${google_compute_instance_template.k8s-worker.self_link}"
  update_strategy    = "MIGRATE"
  zone               = "${var.zone}"

  target_size  = "${var.worker_count}"
}
