resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster"
}


resource "aws_ecs_task_definition" "app" {
  family                   = "app-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = <<DEFINITION
[
  {
    "name": "${var.image_repo_name}",
    "image": "${jsondecode(data.aws_secretsmanager_secret_version.account_id.secret_string)["AWS_ACCOUNT_ID"]}.dkr.ecr.${var.region}.amazonaws.com/${var.image_repo_name}:${var.docker_tag}",
    "essential": true,
    "networkMode": "awsvpc",
    "entryPoint": []
     "runtimePlatform": {
        "operatingSystemFamily": "LINUX"
    },
   "requiresCompatibilities": [ 
       "FARGATE" 
    ],
    "portMappings": [
      {  
        
        "containerPort": 3000,
        "hostPort": 3000
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.app.name}",
        "awslogs-region": "${var.region}",
        "awslogs-stream-prefix": "/ecs/${var.name}"
      }
    }
  }
]
DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

resource "aws_ecs_service" "main" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  force_new_deployment = true 
  scheduling_strategy = "REPLICA"
  network_configuration {
    security_groups  = [aws_security_group.ecs_sg.id, aws_security_group.alb_ecs_sg.id]
    subnets          = aws_subnet.pri.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.green.arn
    container_name   = var.image_repo_name
    container_port   = var.port

  }
  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [aws_alb_listener.main_blue_green, aws_iam_role_policy_attachment.ecs_task_execution_role]
}