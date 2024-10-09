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
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0866a3c8686eaeeba" // selects region image in aws
  instance_type = "t2.micro"    // default instance for use
  key_name = "iac-first-project" // important to terraform ssh key detection
  tags = {
    Name = "terraform instance aws"
  }
}
