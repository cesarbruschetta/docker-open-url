terraform {
  required_version = ">= 1.1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.12.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2"
    }
  }

}


#----- ECS --------
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"

  cluster_name = "${var.env}-${var.application}"

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "ecs/${var.env}/${var.application}"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 20
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 80
      }
    }
  }

  tags = {
    Environment = var.env
  }
}

#----- ECS  Services--------
module "ecs_service" {
  source = "./ecs_services"

  cluster_id     = module.ecs.cluster_id
  region         = var.region
  ecr_repository = var.ecr_repository_name
  account_id     = var.account_id
  env            = var.env
  application    = var.application
}
