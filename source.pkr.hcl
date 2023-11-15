source "amazon-ebs" "ubuntu" {
  // ami_name matches these formats:
  //   - linux-cpu-amd64-2.311.0-${timestamp}
  //   - linux-gpu-535-amd64-2.311.0-${timestamp}
  ami_name      = join(
                    "-",
                    [ for v in
                      [
                        var.os,
                        var.variant,
                        local.driver_major_version,
                        var.arch,
                        var.runner_version,
                        local.timestamp
                      ]
                    : v if v != null ]
                  )
  instance_type = local.instance_type
  region        = var.aws_region

  temporary_security_group_source_public_ip = true
  skip_create_ami = var.skip_create_ami
  shutdown_behavior = "terminate"
  user_data_file = "./cloud-init/user-data"

  source_ami_filter {
    filters = {
      name = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-${var.arch}-server-*"
    }
    most_recent = true
    owners      = ["099720109477"] // Canonical
  }
  ssh_username = "runner"
  ssh_password = "runner"

  // TODO: explore adding `Name` tag here to set AMI name
  // if it's not properly set using `ami_name` attribute above
  tags = {
    for k,v in {
      "arch" = var.arch
      "driver-version" = local.driver_major_version
      "os" = var.os
      "runner-version" = var.runner_version
      "variant" = var.variant
    }: k => v if v != null
  }
}


source "qemu" "ubuntu" {
  iso_url           = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-${var.arch}.img"
  iso_checksum      = "file:https://cloud-images.ubuntu.com/jammy/current/SHA256SUMS"
  disk_image        = true
  shutdown_command  = "echo 'ubuntu' | sudo -S shutdown -P now"
  disk_size         = "150G"
  format            = "qcow2"
  accelerator       = "kvm"
  ssh_username      = "runner"
  ssh_password      = "runner"
  output_directory  = "output"
  vm_name           = "build.qcow2"
  cd_files          = ["./cloud-init/*"]
  cd_label          = "cidata"

  headless = true // comment this line to see the VM during local builds
}