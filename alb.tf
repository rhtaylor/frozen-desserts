resource "aws_alb" "main" {
  name            = "load-balancer"
  subnets         = aws_subnet.pub.*.id
  internal = false
  security_groups = [aws_security_group.lb.id, aws_security_group.ecs_tasks.id]
}

resource "aws_alb_target_group" "blue" {
  name        = "target-group"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "TCP"
    matcher             = "200-299"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }

   depends_on = [ aws_alb.main ]
} 

resource "aws_alb_target_group" "green" {
  name        = "target-group-second"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  

  health_check {
    healthy_threshold   = "4"
    interval            = "60"
    protocol            = "TCP"
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
  port              = "80"
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

}

resource "aws_lb_listener_rule" "blue"{
 listener_arn = aws_alb.main.arn
 priority = 90

 action {
  type = "forward"
  target_group_arn = aws_lb_target_group.blue.arn
 }
# because CodeDeploy will switch target groups during the B/G deployment
 lifecycle {
   ignore_changes = [action] 
 }
   condition {
    host_header {
      values = ["amazonaws.com"]
    }
  }
}