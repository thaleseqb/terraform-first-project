terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

resource "aws_launch_template" "machine" {
  image_id            = "ami-0866a3c8686eaeeba" // selects region image in aws
  instance_type = var.instance // default instance for use
  key_name = var.key // important to terraform ssh key detection
  tags = {
    Name = "terraform ansible python"
  }
  security_group_names = [ var.secutiryGroup ]
}

resource "aws_key_pair" "ssh-key" {
  key_name = var.key
  public_key = file("${var.key}.pub")
}

resource "aws_autoscaling_group" "autoscaling_group" {
  availability_zones = [ "${var.aws_region}a" ]
  name = var.groupName
  max_size = var.maxSize
  min_size = var.minSize
  launch_template {
    id = aws_launch_template.machine.id
    version = "$Latest"
  }
}