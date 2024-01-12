resource "aws_alb" "main" {
  name            = "load-balancer"
  subnets         = aws_subnet.pub.*.id
  security_groups = [aws_security_group.lb.id, aws_security_group.ecs_tasks.id]
}

resource "aws_alb_target_group" "blue" {
  name        = "target-group"
  port        = "3000"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "4"
    interval            = "60"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

   depends_on = [ aws_alb.main, aws_security_group.ecs_tasks ]
} 

resource "aws_alb_target_group" "green" {
  name        = "target-group-second"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200-299"
    timeout             = "5"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

  depends_on = [ aws_alb.main ]
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "blue" {
  load_balancer_arn = aws_alb.main.id
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.blue.id
    type             = "forward"
  }
}

resource "aws_alb_listener" "green" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.green.id
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [default_action]
  }
}



# resource "aws_alb_listener" "application_redirection" {
#   load_balancer_arn = aws_alb.main.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "3000"
#       protocol    = "HTTP"
#       status_code = "HTTP_301"
#     }
#   }
# }