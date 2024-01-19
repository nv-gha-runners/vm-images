source "amazon-ebs" "ubuntu" {
  ami_name      = local.image_id
  instance_type = local.instance_type
  region        = var.aws_region

  skip_create_ami   = !var.upload_ami
  shutdown_behavior = "terminate"
  user_data_file    = "./linux/init/user-data"

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-${var.arch}-server-*"
    }
    most_recent = true
    owners      = ["099720109477"] // Canonical
  }
  vpc_filter {
    filters = {
      "is-default" : "true"
    }
  }
  security_group_filter {
    filters = {
      "group-name" : "default"
    }
  }
  ssh_username         = "runner"
  ssh_password         = "runner"
  ssh_interface        = "session_manager"
  iam_instance_profile = "runner_profile" // this profile is created in Terraform

  // These tags are used for cleaning up resources during GHAs provisioning
  // and cleaning up old AMIs when new ones are created.
  run_tags = {
    "gh-run-id"  = var.gh_run_id,
    "image-name" = var.image_name,
    "vm-images"  = "true",
  }

  tags = {
    for k, v in {
      "arch"           = var.arch
      "driver-version" = var.driver_version
      "os"             = var.os
      "runner-version" = var.runner_version
      "variant"        = local.variant
      "Name"           = local.image_id
    } : k => v if v != ""
  }
}

// A dummy source to enable shell-local provisioners to run before the QEMU
// build runs
source "null" "qemu_dependencies" {
  communicator = "none"
}

source "qemu" "ubuntu" {
  cpus             = 4
  disk_image       = true
  disk_size        = "150G"
  format           = "qcow2"
  headless         = var.headless
  // FIXME: change pin from `20240115` to `current` after a new release is out.
  // `20240117` has SSH issues that prevent CI from completing.
  iso_checksum     = "file:https://cloud-images.ubuntu.com/jammy/20240115/SHA256SUMS"
  iso_url          = "https://cloud-images.ubuntu.com/jammy/20240115/jammy-server-cloudimg-${var.arch}.img"
  memory           = 2048
  output_directory = local.output_directory
  qemu_binary      = "qemu-system-${lookup(local.qemu_arch, var.arch, "")}"
  qemuargs = [
    ["-machine", "${lookup(local.qemu_machine, var.arch, "")},accel=kvm"],
    ["-cpu", "host"],
    ["-device", "virtio-gpu-pci"], // this is needed for arm64 QEMU machine to boot
    ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=/usr/share/${lookup(local.uefi_imp, var.arch, "")}/${lookup(local.uefi_imp, var.arch, "")}_CODE.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=${lookup(local.uefi_imp, var.arch, "")}_VARS.fd"],
    ["-drive", "file=${local.output_directory}/${local.output_filename},format=qcow2"],
    ["-drive", "file=cloud-init.iso,format=raw"]
  ]
  shutdown_command       = "echo 'ubuntu' | sudo -S shutdown -P now"
  ssh_handshake_attempts = 30
  ssh_password           = "runner"
  ssh_username           = "runner"
  vm_name                = local.output_filename
}
