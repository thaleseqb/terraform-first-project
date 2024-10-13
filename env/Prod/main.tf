module "aws-prod" {
  source = "../../infra"
  instance = "t2.micro"
  aws_region = "us-east-1"
  key = "Iac-PROD"
  secutiryGroup = "Production"
  minSize = 1
  maxSize = 10
  groupName = "PROD"
}
