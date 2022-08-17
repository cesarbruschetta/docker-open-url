terraform {
  required_version = ">= 1.1.8"

  backend "s3" {
    bucket = "dev-datalake-artifact-643626749185"
    key    = "terraform/state/open-url.tfstate"
    region = "us-east-1"
  }

}

provider "aws" {
  alias = "aws_default"
  region = var.aws_region
}

#----- AWS PROVIVER --------
# module "ecs" {
#   source = "./aws"
#   providers = {
#     aws = aws.aws_default
#   }
  
#   account_id = var.aws_account_id
#   region = var.aws_region
  
# }
