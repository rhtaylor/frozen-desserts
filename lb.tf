resource "aws_alb" "main" {
  name            = "load-balancer"
  subnets         = aws_subnet.pub.*.id
  internal = false
  security_groups = [aws_security_group.lb.id, aws_security_group.ecs_tasks.id]
}

locals {
  target_port = 3000
}


resource "aws_security_group" "alb_ecs_sg" {
    vpc_id = aws_vpc.main.vpc_id

    ingress {
        protocol         = "tcp"
        from_port        = "80"
        to_port          = "80"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ## Allow outbound to ecs instances in private subnet
    egress {
        protocol    = "tcp"
        from_port   = local.target_port
        to_port     = local.target_port
        cidr_blocks = aws_subnet.pri[*].cidr_block
    }
}

resource "aws_security_group" "ecs_sg" {
    vpc_id = aws_vpc.main.vpc_id
    ingress {
        protocol         = "tcp"
        from_port        = "80"
        to_port          = "80"
        security_groups  = [aws_security_group.alb_ecs_sg.id]
    }
      egress {
        protocol         = -1
        from_port        = 0
        to_port          = 0
        cidr_blocks      = ["0.0.0.0/0"]
    }
}

resource "aws_alb_target_group" "blue" {
  name        = "target-group-blue"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

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

resource "aws_alb_listener" "blue" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"
  
  default_action {
    target_group_arn = aws_alb_target_group.blue.id
    type             = "forward"
  }
 
}

resource "aws_alb_target_group" "green" {
  name        = "target-group-green"
  port        = "80"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

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