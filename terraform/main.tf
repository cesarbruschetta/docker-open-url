terraform {
  required_version = ">= 1.1.8"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

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

provider "digitalocean" {
  alias = "digitalocean_default"
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

# ----- DIGITAL OCEAN PROVIVER --------
module "k8s" {
  source = "./digitalocean"
  providers = {
    digitalocean = digitalocean.digitalocean_default
  }
  
  region = var.digitalocean_region
  open_browser_url = var.OPEN_BROWSER_URL
  count_replicas = var.COUNT_REPLICAS
  
}

