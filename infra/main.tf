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

resource "aws_instance" "app_server" {
  ami           = "ami-0866a3c8686eaeeba" // selects region image in aws
  instance_type = var.instance // default instance for use
  key_name = var.key // important to terraform ssh key detection
  tags = {
    Name = "terraform ansible python"
  }
}

resource "aws_key_pair" "ssh-key" {
  key_name = var.key
  public_key = file("${var.key}.pub")
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}