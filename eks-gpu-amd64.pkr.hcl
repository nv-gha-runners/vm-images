packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "driver_version" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

variable "skip_create_ami" {
  type    = bool
  default = false
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  vpc_id = "vpc-81eb9ae9"
  subnet_id = "subnet-45f29e2d"
}

source "amazon-ebs" "eks_gpu_amd64" {
  ami_name      = "eks-gpu-amd64-${var.kubernetes_version}-${split(".", var.driver_version)[0]}-${local.timestamp}"
  instance_type = var.instance_type
  region        = var.aws_region

  vpc_id = local.vpc_id
  subnet_id = local.subnet_id
  associate_public_ip_address = true
  temporary_security_group_source_public_ip = true

  skip_create_ami = var.skip_create_ami

  source_ami_filter {
    filters = {
      name = "amazon-eks-node-${var.kubernetes_version}-*"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  ssh_username = "ec2-user"

  tags = {
    "k8s-version": "${var.kubernetes_version}",
    "driver-version": "${split(".", var.driver_version)[0]}",
    "arch": "amd64"
  }
}

build {
  sources = [
    "source.amazon-ebs.eks_gpu_amd64"
  ]

  provisioner "ansible" {
    user = "ec2-user"
    playbook_file = "ansible/run.yaml"
    extra_arguments = ["--extra-vars", "driver_version=${var.driver_version}"]
    galaxy_file = "ansible/requirements.yaml"
    roles_path = "ansible/roles"
    use_proxy  = false
  }
}
