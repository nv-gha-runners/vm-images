source "amazon-ebs" "ubuntu" {
  ami_name      = local.img_name
  instance_type = local.instance_type
  region        = var.aws_region

  temporary_security_group_source_public_ip = true
  skip_create_ami                           = var.skip_create_ami
  shutdown_behavior                         = "terminate"
  user_data_file                            = "./cloud-init/user-data"

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-${var.arch}-server-*"
    }
    most_recent = true
    owners      = ["099720109477"] // Canonical
  }
  ssh_username = "runner"
  ssh_password = "runner"

  run_tags = {
    "vm-images" = "true",
    "run-id"    = var.run_id
  }

  tags = {
    for k, v in {
      "arch"           = var.arch
      "driver-version" = var.driver_version
      "os"             = var.os
      "runner-version" = var.runner_version
      "variant"        = local.variant
      "Name"           = local.img_name
    } : k => v if v != ""
  }
}


source "qemu" "ubuntu" {
  iso_url          = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-${var.arch}.img"
  iso_checksum     = "file:https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
  disk_image       = true
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  cores            = 4
  memory           = 2048
  disk_size        = "150G"
  format           = "qcow2"
  accelerator      = "kvm"
  ssh_username     = "runner"
  ssh_password     = "runner"
  output_directory = "output"
  vm_name          = "build.qcow2"
  cd_files         = ["./cloud-init/*"]
  cd_label         = "cidata"

  headless = true // comment this line to see the VM during local builds
}
