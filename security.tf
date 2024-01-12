resource "aws_security_group" "lb" {
  name        = "load-balancer-security-group"
  description = "controls access to the ALB"
  vpc_id      = aws_vpc.main.id
  tags = var.tags

  ingress {
    protocol    = "TCP"
    from_port   = "80"
    to_port     = "80"
    cidr_blocks = ["0.0.0.0/0"]
   
  }

  egress {
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Traffic to the ECS cluster should only come from the ALB
resource "aws_security_group" "ecs_tasks" {
  name        = "ecs-tasks-security-group"
  description = "allow inbound access from the ALB only"
  vpc_id      = aws_vpc.main.id
  tags = var.tags
  ingress {
    protocol        = "TCP"
    from_port       = "3000"
    to_port         = "3000"
    security_groups = [aws_security_group.lb.id]
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
  }
}