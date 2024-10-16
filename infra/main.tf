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
  user_data = var.production ? filebase64("ansible.sh") : ""
}

resource "aws_key_pair" "ssh-key" {
  key_name = var.key
  public_key = file("${var.key}.pub")
}

resource "aws_autoscaling_group" "autoscaling_group" {
  availability_zones = [ "${var.aws_region}a","${var.aws_region}b" ]
  name = var.groupName
  max_size = var.maxSize
  min_size = var.minSize
  launch_template {
    id = aws_launch_template.machine.id
    version = "$Latest"
  }
  target_group_arns = var.production ? [ aws_lb_target_group.lb_target_group[0].arn ]: []
}

resource "aws_default_subnet" "first_subnet" {
  availability_zone = "${var.aws_region}a"
}

resource "aws_default_subnet" "second_subnet" {
  availability_zone = "${var.aws_region}b"
}

resource "aws_lb" "loadBalancer" {
  internal = false
  subnets = [ aws_default_subnet.first_subnet.id, aws_default_subnet.second_subnet.id ]
  count = var.production ? 1 : 0
}

resource "aws_default_vpc" "default" {
  
}

resource "aws_lb_target_group" "lb_target_group" {
  name = "targetMachines"
  port = "8000"
  protocol = "HTTP"
  vpc_id = aws_default_vpc.default.id
  count = var.production ? 1 : 0
}

resource "aws_lb_listener" "input_loadbalancer" {
  load_balancer_arn = aws_lb.loadBalancer[0].arn
  port = "8000"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group[0].arn
  }
  count = var.production ? 1 : 0
}

resource "aws_autoscaling_policy" "asPolicyProd" {
  name = "terraformScaling"
  autoscaling_group_name = var.groupName
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
  count = var.production ? 1 : 0
}