// A dummy source to enable shell-local provisioners to run before the actual
// provisioning begins
source "null" "preprovision" {
  communicator = "none"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = local.image_id
  instance_type = local.instance_type
  region        = var.default_aws_region
  ami_regions   = split(",", var.backup_aws_regions)

  skip_create_ami   = !var.upload_ami
  shutdown_behavior = "terminate"
  user_data_file    = "./linux/init/user-data"

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-${var.arch}-server-20241217"
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
  region        = var.default_aws_region
  ami_regions   = split(",", var.backup_aws_regions)

  skip_create_ami = !var.upload_ami
  aws_polling {
    delay_seconds = 45
    max_attempts  = 120
  }
  shutdown_behavior = "terminate"
  # the `user_data` file for AWS must be wrapped in a <powershell> tag
  user_data = <<-EOF
  <powershell>
  ${file("${path.root}/windows/init/bootstrap.ps1")}
  </powershell>
  EOF

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

  communicator = "ssh"
  ssh_username = "Administrator"
  # password must meet complexity requirements:
  # https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements
  ssh_password         = "Runner1!"
  ssh_interface        = "session_manager"
  iam_instance_profile = "runner_profile" // this profile is created in Terraform

  // These tags are used for cleaning up resources during GHAs provisioning
  // and cleaning up old AMIs when new ones are created.
  run_tags = local.ami_run_tags

  tags = local.ami_tags
}

source "qemu" "windows" {
  cpus             = 8
  disk_size        = "150G"
  memory           = 8192
  format           = "qcow2"
  headless         = var.headless
  iso_checksum     = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
  iso_urls         = ["https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"]
  output_directory = local.output_directory
  qemu_binary      = "qemu-system-${local.qemu_arch}"
  machine_type     = "q35"
  accelerator      = "kvm"
  net_device       = "virtio-net-pci"

  # Disk space optimizations for detecting TRIM on Windows
  disk_interface     = "virtio-scsi"
  disk_discard       = "unmap"
  disk_detect_zeroes = "unmap"
  # Disk compression is *not* fast, maybe we consider enabling this inside the VM instead
  # Currently compresses to about 6gb
  #  disk_compression   = true
  skip_compaction = false

  floppy_files = [
    "windows/init/Autounattend.xml",
    "windows/init/bootstrap.ps1"
  ]

  qemuargs = [
    ["-cpu", "host"],
    ["-cdrom", "./local/virtio-win.iso"]
  ]

  communicator = "ssh"
  ssh_username = "Administrator"
  # password must meet complexity requirements:
  # https://learn.microsoft.com/en-us/windows/security/threat-protection/security-policy-settings/password-must-meet-complexity-requirements
  ssh_password = "Runner1!"

  vm_name = local.output_filename
}
