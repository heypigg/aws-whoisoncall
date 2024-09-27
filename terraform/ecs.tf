resource "aws_ecs_cluster" "oncallwebsite" {
  name = "go-mets"
}

# resource "aws_ecs_cluster" "test" {
#   name = "example"

#   configuration {
#     execute_command_configuration {
#       #kms_key_id = aws_kms_key.example.arn
#       logging    = "OVERRIDE"

#     #   log_configuration {
#     #     cloud_watch_encryption_enabled = true
#     #     cloud_watch_log_group_name     = aws_cloudwatch_log_group.example.name
#     #   }
#     }
#   }
# }


resource "aws_ecs_task_definition" "oncallwebsite_task" {
  family                   = "oncallwebsite"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # Adjust as needed
  memory                   = "512"  # Adjust as needed
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "server-app"
      image     = "${var.account_number}.dkr.ecr.us-east-1.amazonaws.com/oncallwebsite:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 3001
          hostPort      = 3001
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "oncallwebsite_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.oncallwebsite.id
  task_definition = aws_ecs_task_definition.oncallwebsite_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets         = ["data.aws_subnet.default.ids"]
    #security_groups = ["<security_group_id>"]
    assign_public_ip = true
  }
}


## Build Container Registry
resource "aws_ecr_repository" "oncallwebsite_ecr_repo" {
  name = "oncallwebsite-repo" # Name of the ECR repository

  image_scanning_configuration {
    scan_on_push = true
  }

  # encryption_configuration {
  #   encryption_type = "AES256" # Default encryption, or use "KMS" for using AWS KMS keys
  # }

  tags = {
    Environment = "dev"
    Project     = "oncallwebsite"
  }
}