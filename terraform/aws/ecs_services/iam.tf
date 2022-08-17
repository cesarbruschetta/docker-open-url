resource "aws_iam_role" "role" {
  name = "${var.env}-${var.application}_ecs_taskExecution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = [
          "ecs.amazonaws.com",
          "cloudwatch.amazonaws.com",
          "ecs-tasks.amazonaws.com",
        ]
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    env               = var.env
  }
}

resource "aws_iam_role_policy_attachment" "task" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
