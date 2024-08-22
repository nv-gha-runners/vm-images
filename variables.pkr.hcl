variable "arch" {
  type        = string
  default     = "amd64"
  description = "The architecture of the runner. Valid values are 'amd64' or 'arm64'."

  validation {
    condition     = can(regex("^a(md|rm)64$", var.arch))
    error_message = "The arch value must be either 'amd64' or 'arm64'."
  }
}

variable "backup_aws_regions" {
  type        = string
  description = "A comma-separated list of the AWS regions to copy the AMIs to."
}

variable "default_aws_region" {
  type        = string
  description = "The AWS region to provision EC2 instances in."
}

variable "driver_version" {
  type        = string
  default     = ""
  description = "The NVIDIA driver version to install on the EC2 instance. If empty, no driver will be installed."

  validation {
    condition     = can(regex("(^\\d{3}\\.\\d{2,3}\\.\\d{2,3}$|^$)", var.driver_version))
    error_message = "The driver_version value must be an empty string or 3 groups of digits splitted by dots."
  }
}

variable "gh_run_id" {
  type        = string
  default     = ""
  description = "The GitHub run ID. Used to clean up Packer resources in AWS."
}

variable "gh_token" {
  type        = string
  default     = ""
  description = "A GitHub token used to authenticate GitHub API calls."
}

variable "headless" {
  type        = bool
  default     = false
  description = "Whether VNC viewer should not be launched."
}

variable "image_name" {
  type        = string
  default     = ""
  description = "The name of the image. Used to clean up Packer resources in AWS."
}

variable "os" {
  type        = string
  default     = "linux"
  description = "The operating system of the runner. Valid values are 'linux' or 'windows'."

  validation {
    condition     = can(regex("^(linux|windows)$", var.os))
    error_message = "The arch value must be either 'linux' or 'windows'."
  }
}

variable "runner_env" {
  type        = string
  description = "The environment of the runner. Valid values are 'aws' or 'qemu'."

  validation {
    condition     = can(regex("(^aws$|^qemu$)", var.runner_env))
    error_message = "The runner_env value must be 'aws' or 'qemu'."
  }
}

variable "runner_version" {
  type        = string
  description = "The version of the runner to install. Must be in the format 'x.y.z'."

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.runner_version))
    error_message = "The runner_version value must match the pattern '^\\d+\\.\\d+\\.\\d+$'."
  }
}

variable "upload_ami" {
  type        = bool
  default     = false
  description = "Whether to create the AMI."
}

variable "timestamp" {
  type        = string
  default     = ""
  description = "A timestamp used to create unique names for resources."
}
