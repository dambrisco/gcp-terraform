variable "prefix" {
  default = ""
}

variable "etcd_discovery_url" {
  default = ""
}

variable "zones" {
  default = "us-east1-b"
}

variable "default-instance-type" {
  default = "n1-standard-1"
}

variable "default-image" {
  default = "coreos-stable-899-17-0-v20160504"
}

variable "whitelisted-ips" {
  default = ""
}
