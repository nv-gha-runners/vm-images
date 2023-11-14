locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  driver_major_version = var.variant == "cpu" ? null : "${split(".", var.driver_version)[0]}"
  instance_type = var.arch == "amd64" ? "m7i.large" : "m7g.large"
}
