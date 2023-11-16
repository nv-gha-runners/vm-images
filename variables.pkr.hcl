variable "arch" {
  type    = string
  default = "amd64"

  validation {
    condition     = can(regex("^a(md|rm)64$", var.arch))
    error_message = "The arch value must be either 'amd64' or 'arm64'."
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "driver_version" {
  type = string
  default = ""

  validation {
    condition     = can(regex("(^\\d{3}$|^$)", var.driver_version))
    error_message = "The driver_version value must be an empty string or 3 digits."
  }
}

variable "runner_env" {
  type = string

  validation {
    condition     = can(regex("(^aws$|^premise$)", var.runner_env))
    error_message = "The runner_env value must be 'aws' or 'premise'."
  }
}

variable "os" {
  type    = string
  default = "linux"

  validation {
    condition     = can(regex("^(linux|win)$", var.os))
    error_message = "The arch value must be either 'linux' or 'win'."
  }
}

variable "runner_version" {
  type     = string

  validation {
    condition     = can(regex("^\\d+\\.\\d+\\.\\d+$", var.runner_version))
    error_message = "The runner_version value must match the pattern '^\\d+\\.\\d+\\.\\d+$'."
  }
}

variable "skip_create_ami" {
  type    = bool
  default = true
}
