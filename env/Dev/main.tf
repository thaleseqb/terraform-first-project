module "aws-dev" {
  source = "../../infra"
  instance = "t2.micro"
  aws_region = "us-east-1"
  key = "Iac-DEV"
  secutiryGroup = "DEV"
  minSize = 0
  maxSize = 1
  groupName = "DEV"
  production = false
}
