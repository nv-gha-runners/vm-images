build {
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.qemu.ubuntu",
  ]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
      "mkdir -p ${local.helpers_directory}"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/scripts/helpers/"
    destination = "${local.helpers_directory}"
  }

  provisioner "file" {
    source      = "${path.root}/config.yaml"
    destination = "${local.helpers_directory}/config.yaml"
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "NV_ARCH=${var.arch}",
      "NV_DRIVER_VERSION=${var.driver_version}",
      "NV_HELPER_SCRIPTS=${local.helpers_directory}",
      "NV_RUNNER_ENV=${var.runner_env}",
      "NV_RUNNER_VERSION=${var.runner_version}",
      "NV_VARIANT=${local.variant}",
    ]

    scripts = [
      // Core pkgs used in subsequent scripts
      "${path.root}/scripts/installers/apt.sh",
      "${path.root}/scripts/installers/jq.sh",
      "${path.root}/scripts/installers/yq.sh",

      // NVIDIA CTK & Driver
      "${path.root}/scripts/installers/nvidia-driver.sh",

      // Remaining Packages
      "${path.root}/scripts/installers/awscli.sh",
      "${path.root}/scripts/installers/docker.sh",
      "${path.root}/scripts/installers/gh.sh",
      "${path.root}/scripts/installers/git.sh",
      "${path.root}/scripts/installers/nvidia-container-toolkit.sh",
      "${path.root}/scripts/installers/nvme.sh",
      "${path.root}/scripts/installers/python.sh",
      "${path.root}/scripts/installers/runner.sh",

      // Cleanup
      "${path.root}/scripts/installers/cleanup.sh",
    ]
  }

  provisioner "shell" {
    inline = [
      "rm -rf ${local.helpers_directory}"
    ]
  }
}
