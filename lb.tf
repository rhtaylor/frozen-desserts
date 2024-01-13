resource "aws_alb" "main" {
  name            = "load-balancer"
  subnets         = aws_subnet.pub.*.id
  internal = false
  security_groups = [ aws_security_group.fargate.id]
}

locals {
  target_port = 3000
}

resource "aws_lb_listener" "blue" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "tcp"

  default_action {
    type             = "foward"
    target_group_arn = aws_lb_target_group.fargate.arn
  }
}
resource "aws_lb_listener" "green" {
  load_balancer_arn = aws_alb.main.arn
  port              = "80"
  protocol          = "tcp"

  default_action {
    type             = "foward"
    target_group_arn = aws_lb_target_group.fargate.arn
  }
}

resource "aws_lb_target_group" "fargate" {
  name        = "${var.name}-tg"
  port        = "80"
  protocol    = "tcp"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
}

resource "aws_security_group" "green" {
  name        = "HTTP_Access"
  description = "Allow HTTP/SSH inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# // AWS ELB Target Blue groups/Listener for Blue/Green Deployments
resource "aws_lb_target_group" "blue" {
  name        = "${var.name}-blue"
  port        = 80
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.vpc_id
}

# // AWS ELB Target Green groups/Listener for Blue/Green Deployments
# resource "aws_lb_target_group" "green" {
#   name        = "${var.name}-green"
#   port        = 80
#   protocol    = "TCP"
#   target_type = "ip"
#   vpc_id      = aws_vpc.main.vpc_id
# }

# resource "aws_lb_listener" "main_blue_green" {
#   load_balancer_arn = aws_alb.main.arn
#   protocol          = "TCP"
#   port              = var.port

#   depends_on = [aws_lb_target_group.blue]

#   default_action {
#     target_group_arn = aws_lb_target_group.blue.arn
#     type             = "forward"
#   }

#   lifecycle {
#     ignore_changes = [default_action]
#   }
# }

# // AWS ELB Test Listener port application to test traffic before rerouting
# resource "aws_lb_listener" "main_test_blue_green" {
#   load_balancer_arn = aws_alb.main.arn
#   protocol          = "TCP"
#   port              = var.port

#   depends_on = [aws_lb_target_group.blue]

#   default_action {
#     target_group_arn = aws_lb_target_group.blue.arn
#     type             = "forward"
#   }

#   lifecycle {
#     ignore_changes = [default_action]
#   }
# }

# resource "aws_security_group" "alb_ecs_sg" {
#     vpc_id = aws_vpc.main.vpc_id

#     ingress {
#         protocol         = "HTTP"
#         from_port        = "80"
#         to_port          = "80"
#         cidr_blocks      = ["0.0.0.0/0"]
#     }

#     ## Allow outbound to ecs instances in private subnet
#     egress {
#         protocol    = "HTTP"
#         from_port   = local.target_port
#         to_port     = local.target_port
#         cidr_blocks = aws_subnet.pri[*].cidr_block
#     }
# }

# resource "aws_security_group" "ecs_sg" {
#     vpc_id = aws_vpc.main.vpc_id
#     ingress {
#         protocol         = "HTTP"
#         from_port        = "0"
#         to_port          = "3000"
#         security_groups  = [aws_security_group.alb_ecs_sg.id]
#     }
#       egress {
#         protocol         = -1
#         from_port        = 0
#         to_port          = 0
#         cidr_blocks      = ["0.0.0.0/0"]
#     }
# }

# # resource "aws_alb_target_group" "blue" {
# #   name        = "target-group-blue"
# #   port        = "80"
# #   protocol    = "HTTP"
# #   vpc_id      = aws_vpc.main.id
# #   target_type = "ip"

# #   health_check {
# #     healthy_threshold   = "3"
# #     interval            = "30"
# #     protocol            = "HTTP"
# #     matcher             = "200-499"
# #     timeout             = "3"
# #     path                = var.health_check_path
# #     unhealthy_threshold = "2"
# #   }

# #    depends_on = [ aws_alb.main ]
# # } 

# # resource "aws_alb_listener" "blue" {
# #   load_balancer_arn = aws_alb.main.id
# #   port              = "80"
# #   protocol          = "HTTP"
  
# #   default_action {
# #     target_group_arn = aws_alb_target_group.blue.id
# #     type             = "forward"
# #   }
 
# # }

# # resource "aws_alb_target_group" "green" {
# #   name        = "target-group-green"
# #   port        = "80"
# #   protocol    = "HTTP"
# #   vpc_id      = aws_vpc.main.id
# #   target_type = "ip"

# #   health_check {
# #     healthy_threshold   = "3"
# #     interval            = "30"
# #     protocol            = "HTTP"
# #     matcher             = "200-499"
# #     timeout             = "5"
# #     path                = var.health_check_path
# #     unhealthy_threshold = "2"
# #   }

# #   depends_on = [ aws_alb.main ]
# # }

# # resource "aws_alb_listener" "green" {
# #   load_balancer_arn = aws_alb.main.id
# #   port              = "80"
# #   protocol          = "HTTP"

# #   default_action {
# #     target_group_arn = aws_alb_target_group.green.id
# #     type             = "forward"
# #   }

# # }

# # resource "aws_lb_listener_rule" "green"{
# #  listener_arn = aws_alb.main.arn
# #  priority = 90

# #  action {
# #   type = "forward"
# #   target_group_arn = aws_lb_target_group.green.arn
# #  }
# # # because CodeDeploy will switch target groups during the B/G deployment
# #  lifecycle {
# #    ignore_changes = [action] 
# #  }
# #    condition {
# #     host_header {
# #       values = ["amazonaws.com"]
# #     }
# #   }
# # }