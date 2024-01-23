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
  run_tags = local.ami_run_tags

  tags = local.ami_tags
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
  iso_checksum     = "file:https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
  iso_url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-${var.arch}.img"
  memory           = 2048
  output_directory = local.output_directory
  qemu_binary      = "qemu-system-${local.qemu_arch}"
  qemuargs = [
    ["-machine", "${local.qemu_machine},accel=kvm"],
    ["-cpu", "host"],
    ["-device", "virtio-gpu-pci"], // this is needed for arm64 QEMU machine to boot
    ["-drive", "if=pflash,format=raw,id=ovmf_code,readonly=on,file=/usr/share/${local.uefi_imp}/${local.uefi_imp}_CODE.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=${local.uefi_imp}_VARS.fd"],
    ["-drive", "file=${local.output_directory}/${local.output_filename},format=qcow2"],
    ["-drive", "file=cloud-init.iso,format=raw"]
  ]
  shutdown_command       = "echo 'ubuntu' | sudo -S shutdown -P now"
  ssh_handshake_attempts = 30
  ssh_password           = "runner"
  ssh_username           = "runner"
  vm_name                = local.output_filename
}

source "amazon-ebs" "windows" {
  ami_name      = local.image_id
  instance_type = local.instance_type
  region        = var.aws_region

  skip_create_ami   = !var.upload_ami
  shutdown_behavior = "terminate"
  user_data_file    = "./win/init/bootstrap.ps1"

  source_ami_filter {
    filters = {
      name                = "Windows_Server-2022-English-Core-Base*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
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

  communicator         = "ssh"
  ssh_username         = "runner"
  ssh_password         = "runner"
  ssh_interface        = "session_manager"
  iam_instance_profile = "runner_profile" // this profile is created in Terraform

  // These tags are used for cleaning up resources during GHAs provisioning
  // and cleaning up old AMIs when new ones are created.
  run_tags = local.ami_run_tags

  tags = local.ami_tags
}
