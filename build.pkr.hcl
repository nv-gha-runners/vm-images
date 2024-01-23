build {
  source "source.null.qemu_dependencies" {
    name = "linux-premise"
  }

  provisioner "shell-local" {
    inline = [
      "cp /usr/share/${local.uefi_imp}/${local.uefi_imp}_VARS.fd ${local.uefi_imp}_VARS.fd",
      "cloud-localds cloud-init.iso linux/init/{user,meta}-data"
    ]
    inline_shebang = "/bin/bash -e"
  }
}

build {
  source "source.amazon-ebs.ubuntu" {
    name = "linux-aws"
  }

  source "source.qemu.ubuntu" {
    name = "linux-premise"
  }

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "mkdir -p ${local.context_directory}"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/linux/context/"
    destination = "${local.context_directory}"
  }

  provisioner "file" {
    source      = "${path.root}/config.yaml"
    destination = "${local.context_directory}/config.yaml"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "GH_TOKEN=${var.gh_token}",
      "NV_ARCH=${var.arch}",
      "NV_DRIVER_VERSION=${var.driver_version}",
      "NV_CONTEXT_DIR=${local.context_directory}",
      "NV_EXE_DIR=${local.exe_directory}",
      "NV_RUNNER_ENV=${var.runner_env}",
      "NV_RUNNER_VERSION=${var.runner_version}",
      "NV_VARIANT=${local.variant}",
    ]

    scripts = [
      // Core pkgs used in subsequent scripts
      "${path.root}/linux/installers/apt.sh",
      "${path.root}/linux/installers/jq.sh",
      "${path.root}/linux/installers/yq.sh",

      // NVIDIA CTK & Driver
      "${path.root}/linux/installers/nvidia-driver.sh",

      // Remaining Packages
      "${path.root}/linux/installers/awscli.sh",
      "${path.root}/linux/installers/docker.sh",
      "${path.root}/linux/installers/gh.sh",
      "${path.root}/linux/installers/git.sh",
      "${path.root}/linux/installers/nvidia-container-toolkit.sh",
      "${path.root}/linux/installers/python.sh",
      "${path.root}/linux/installers/runner.sh",

      // Cleanup
      "${path.root}/linux/installers/cleanup.sh",
    ]
  }

  provisioner "shell" {
    inline = [
      "rm -rf ${local.context_directory}"
    ]
  }
}

build {
  source "source.amazon-ebs.windows" {
    name = "win-aws"
  }

  provisioner "powershell" {
    inline = ["mkdir ${local.context_directory}"]
  }

  provisioner "file" {
    source      = "${path.root}/win/context/"
    destination = "${local.context_directory}"
  }

  provisioner "file" {
    source      = "${path.root}/config.yaml"
    destination = "${local.context_directory}/config.yaml"
  }

  provisioner "powershell" {
    environment_vars = [
      "NV_CONTEXT_DIR=${local.context_directory}",
      "NV_EXE_DIR=${local.exe_directory}",
      "NV_RUNNER_ENV=${var.runner_env}",
      "NV_RUNNER_VERSION=${var.runner_version}",
      "NV_VARIANT=${local.variant}",
    ]

    scripts = [
      "${path.root}/win/installers/jq.ps1",
      "${path.root}/win/installers/yq.ps1",
      "${path.root}/win/installers/docker.ps1",
      "${path.root}/win/installers/git.ps1",
      "${path.root}/win/installers/runner.ps1",
    ]
  }

  provisioner "windows-restart" {}

  provisioner "powershell" {
    scripts = ["${path.root}/win/context/docker_imgs.ps1"]
  }

  provisioner "powershell" {
    inline = [
      "Remove-Item -Recurse -Force -Path ${local.context_directory} -ErrorAction Ignore"
    ]
  }
}
