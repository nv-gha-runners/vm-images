locals {
  variant           = var.driver_version == "" ? "cpu" : "gpu"
  instance_type     = var.arch == "amd64" ? "m7i.large" : "m7g.large"
  helpers_directory = "/home/runner/helpers"
  image_id = join(
    "-",
    [
      for v in
      [
        var.image_name,
        var.timestamp
      ]
      : v if v != ""
    ]
  )

  qemu_arch = {
    "amd64" = "x86_64"
    "arm64" = "aarch64"
  }
  uefi_imp = {
    "amd64" = "OVMF"
    "arm64" = "AAVMF"
  }
  qemu_machine = {
    "amd64" = "ubuntu"
    "arm64" = "virt"
  }
  output_directory = "output"
  output_filename  = "img.qcow2"
}
