
locals {
  aws_ecr_url            = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com"
  aws_ecr_repository_url = "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_repository}"
  ecr_image_tag          = "latest"
}


data "aws_ecr_image" "docker_image" {
  depends_on = [
    null_resource.ecr_image
  ]
  repository_name = var.ecr_repository
  image_tag       = local.ecr_image_tag
}


resource "aws_cloudwatch_log_group" "logger" {
  name              = "${var.env}-${var.application}"
  retention_in_days = 1

  tags = {
    Environment = var.env
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.env}-${var.application}"
  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"
  cpu          = 1024
  memory       = 2048

  execution_role_arn = aws_iam_role.role.arn

  container_definitions = jsonencode([
    {
      name        = "${var.env}-${var.application}",
      image       = "${local.aws_ecr_repository_url}:${local.ecr_image_tag}",
      cpu         = 512,
      memory      = 256,
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = "${var.region}",
          awslogs-group         = "${aws_cloudwatch_log_group.logger.name}",
          awslogs-stream-prefix = "${local.ecr_image_tag}"
        }
      }
      environment = [{
        name = "FIREFOX_URL", 
        value = "https://www.youtube.com/watch?v=cfXPlkIVs5k",
      }],
      portMappings = [{
        containerPort = 8088
        hostPort      = 8088
      }]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  tags = {
    Environment = var.env
  }

}

resource "aws_ecs_service" "service" {
  name            = "${var.env}-${var.application}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task.arn
  launch_type     = "FARGATE"
  propagate_tags  = "TASK_DEFINITION"

  desired_count = 1
  force_new_deployment = true

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0

  network_configuration {
    subnets = [
      "subnet-0a3d23394fd13f8d8",
      "subnet-05ea58523757714c4",
      "subnet-0178cb172b50845e5",
      "subnet-0f13b9e3afab8db1c",
      "subnet-045d4346912077e4a",
      "subnet-0e51ac51c36cebaa7",
    ]
    security_groups = [
      "sg-0c9a0b5cc922fb799",
    ]
    assign_public_ip = false
  }

  tags = {
    Environment = var.env
  }
}


resource "null_resource" "ecr_image" {
  triggers = {
    python_files = sha1(
      join(
        "",
        [
          for f in fileset("${path.cwd}/../docker/", "**") :
          filesha1("${path.cwd}/../docker/${f}")
        ]
      )
    )
  }

  provisioner "local-exec" {
    command = <<EOF
        aws ecr get-login-password --region ${var.region} \
        | docker login --username AWS --password-stdin ${local.aws_ecr_url}
        cd ${path.cwd}/../docker/
        docker build \
          --platform linux/amd64 \
          -t ${local.aws_ecr_repository_url}:${local.ecr_image_tag} .
          docker push ${local.aws_ecr_repository_url}:${local.ecr_image_tag}
    EOF
  }
}
