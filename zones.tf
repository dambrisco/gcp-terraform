variable "zone-count" {
  default = "3"
}

variable "zones" {
  default = {
    "zone-0" = "us-east1-b"
    "zone-1" = "us-east1-c"
    "zone-2" = "us-east1-d"
  }
}
