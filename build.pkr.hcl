build {
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.qemu.ubuntu",
  ]

  provisioner "shell" {
    inline = [
      "cloud-init status --wait",
    ]
  }

  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive",
      "NV_ARCH=${var.arch}",
      "NV_DRIVER_VERSION=${var.driver_version}",
    ]

    scripts = [
      // Core pkgs used in subsequent scripts
      "${path.root}/scripts/installers/apt.sh",
      "${path.root}/scripts/installers/jq.sh",
      "${path.root}/scripts/installers/yq.sh",

      // NVIDIA CTK & Driver
      "${path.root}/scripts/installers/nvidia-ctk-and-driver.sh",

      // Remaining Packages
      // "${path.root}/scripts/installers/awscli.sh",
      // "${path.root}/scripts/installers/cmake.sh",
      "${path.root}/scripts/installers/docker.sh",
      "${path.root}/scripts/installers/gh.sh",
      "${path.root}/scripts/installers/git.sh",
      // "${path.root}/scripts/installers/go.sh", // keep?
      // "${path.root}/scripts/installers/miniconda.sh",
      // "${path.root}/scripts/installers/nodejs.sh", // keep?
      // "${path.root}/scripts/installers/python.sh",
      // "${path.root}/scripts/installers/runner.sh",
      // "${path.root}/scripts/installers/rust.sh", // keep?
    ]
  }
}
