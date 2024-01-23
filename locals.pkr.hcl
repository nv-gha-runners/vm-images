locals {
  variant = var.driver_version == "" ? "cpu" : "gpu"
  instance_type_map = {
    "amd64" = "m7i.large"
    "arm64" = "m7g.large"
  }
  instance_type = lookup(local.instance_type_map, var.arch, "")
  context_directory_map = {
    "linux" = "/home/runner/context"
    "win"   = "C:/context"
  }
  context_directory = lookup(local.context_directory_map, var.os, "")
  exe_directory_map = {
    "linux" = "/usr/local/bin"
    "win"   = "C:/tools"
  }
  exe_directory = lookup(local.exe_directory_map, var.os, "")
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

  qemu_arch_map = {
    "amd64" = "x86_64"
    "arm64" = "aarch64"
  }
  qemu_arch = lookup(local.qemu_arch_map, var.arch, "")
  uefi_imp_map = {
    "amd64" = "OVMF"
    "arm64" = "AAVMF"
  }
  uefi_imp = lookup(local.uefi_imp_map, var.arch, "")
  qemu_machine_map = {
    "amd64" = "ubuntu"
    "arm64" = "virt"
  }
  qemu_machine     = lookup(local.qemu_machine_map, var.arch, "")
  output_directory = "output"
  output_filename  = "img.qcow2"

  ami_tags = {
    for k, v in {
      "arch"           = var.arch
      "driver-version" = var.driver_version
      "os"             = var.os
      "runner-version" = var.runner_version
      "variant"        = local.variant
      "Name"           = local.image_id
    } : k => v if v != ""
  }
  ami_run_tags = {
    "gh-run-id"  = var.gh_run_id,
    "image-name" = var.image_name,
    "vm-images"  = "true",
  }
}
