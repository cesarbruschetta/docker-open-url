
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


resource "aws_cloudwatch_log_group" "dev_open_url" {
  name              = "dev_open_url"
  retention_in_days = 1
}

resource "aws_ecs_task_definition" "dev_open_url" {
  family = "dev_open_url"

  container_definitions = <<EOF
[
  {
    "name": "dev_open_url",
    "image": "${local.aws_ecr_repository_url}:${local.ecr_image_tag}",
    "cpu": 1,
    "memory": 256,
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${var.region}",
        "awslogs-group": "${aws_cloudwatch_log_group.dev_open_url.name}",
        "awslogs-stream-prefix": "${local.ecr_image_tag}"
      }
    }
  }
]
EOF
}

resource "aws_ecs_service" "dev_open_url" {
  name            = "dev_open_url"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.dev_open_url.arn

  desired_count = 1

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
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
