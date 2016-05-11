variable "etcd-count" {
  default = 3
}

variable "etcd-image" {
  default = "coreos-stable-899-17-0-v20160504" // DO NOT CHANGE
}

variable "etcd-instance-type" {
  default = ""
}
