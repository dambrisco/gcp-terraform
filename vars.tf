variable "etcd_discovery_url" {}

variable "etcd-count" {
  default = 5
}

variable "worker-count" {
  default = 5
}

variable "etcd-image" {
  default = "coreos-stable-899-17-0-v20160504" // DO NOT CHANGE
}

variable "etcd-instance-type" {
  default = "n1-highcpu-4"
}

variable "worker-image" {
  default = "coreos-stable-899-17-0-v20160504"
}

variable "worker-instance-type" {
  default = "n1-highmem-4"
}

variable "zone" {
  default = "us-central1"
}
