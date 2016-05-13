resource "template_file" "k8s-master-write_files" {
  template = "${file("config/write_files/k8s-master.yml")}"
}

resource "template_file" "k8s-master-units" {
  template = "${file("config/units/k8s-master.yml")}"
}

module "k8s-master-coreos-user-data" {
  source                          = "git::https://github.com/brandfolder/terraform-coreos-user-data.git?ref=master"
  etcd2_initial-cluster           = "${join(",", concat(formatlist("%s=https://%s:%s/", google_compute_address.etcd.*.name, google_compute_address.etcd.*.address, "2380"), formatlist("https://%s:%s/", google_compute_address.etcd.*.name, google_compute_address.etcd.*.address, "7001")))}"
  etcd2_listen-client-urls        = "http://0.0.0.0:2379,http://0.0.0.0:4001"
  etcd2_proxy                     = "on"
  flannel_interface               = "var!private_ipv4"
  fleet_metadata                  = "role=kubernetes,type=master,web=true"
  fleet_public_ip                 = "var!private_ipv4"
  fleet_engine_reconcile_interval = "10"
  fleet_etcd_request_timeout      = "5.0"
  fleet_agent_ttl                 = "120s"
  write_files                     = "${template_file.k8s-master-write_files.rendered}"
  units                           = "${template_file.k8s-master-units.rendered}"
}

resource "google_compute_instance_group_manager" "k8s-master" {
  count       = "${length(split(",", var.zones))}"
  name        = "k8s-master"
  description = "Kubernetes masters"

  base_instance_name = "k8s-master"
  instance_template  = "${google_compute_instance_template.k8s-master.self_link}"
  update_strategy    = "NONE"
  zone               = "${element(split(",", var.zones), count.index % length(split(",", var.zones)))}"

  target_size = "${var.master-count-per-zone}"
}

resource "google_compute_instance_template" "k8s-master" {
  name_prefix = "k8s-master"
  description = "Kubernetes master"

  tags = ["kubernetes", "master", "web"]

  instance_description = "Kubernetes master"
  machine_type         = "${coalesce(var.master-instance-type, var.default-instance-type)}"
  automatic_restart    = true
  on_host_maintenance  = "MIGRATE"

  disk {
    type        = "pd-ssd"
    auto_delete = true
    disk_size_gb        = 100
    source_image       = "${coalesce(var.master-image, var.default-image)}"
  }

  network_interface {
    subnetwork = "${element(google_compute_subnetwork.primary.*.name, count.index % length(split(",", var.zones)))}"

    access_config {
      // Ephemeral IP
    }
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  metadata {
    user-data = "${module.k8s-master-coreos-user-data.user-data}"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
  
  lifecycle {
    create_before_destroy = true
  }
}
