source "amazon-ebs" "ubuntu" {
  ami_name      = local.image_id
  instance_type = local.instance_type
  region        = var.aws_region

  skip_create_ami   = var.skip_create_ami
  shutdown_behavior = "terminate"
  user_data_file    = "./cloud-init/user-data"

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
  vm_name          = "img.qcow2"
  cd_files         = ["./cloud-init/*"]
  cd_label         = "cidata"

  headless = true // comment this line to see the VM during local builds
}
