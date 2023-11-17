locals {
  timestamp         = regex_replace(timestamp(), "[- TZ:]", "")
  variant           = var.driver_version == "" ? "cpu" : "gpu"
  instance_type     = var.arch == "amd64" ? "m7i.large" : "m7g.large"
  helpers_directory = "/home/runner/helpers"
  // img_name matches these formats:
  //   - linux-cpu-amd64-2.311.0-${timestamp}
  //   - linux-gpu-535-amd64-2.311.0-${timestamp}
  img_name = join(
    "-",
    [for v in
      [
        var.os,
        local.variant,
        var.driver_version,
        var.arch,
        var.runner_version,
        local.timestamp
      ]
    : v if v != ""]
  )
}
