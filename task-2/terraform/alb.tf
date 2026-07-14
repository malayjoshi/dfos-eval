# Application Load Balancer (ALB) Resources for SaaS App

# Application Load Balancer definition (Internet-facing)
resource "aws_lb" "external_alb" {
  name               = "${var.environment}-saas-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [for s in aws_subnet.public : s.id]

  enable_deletion_protection = false # Typically true in production

  tags = {
    Name        = "${var.environment}-alb"
    Environment = var.environment
  }
}

# Target Group (Mapping requests to private compute instances / Ingress Controllers)
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.environment}-app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = "/healthz" # Standard Kubernetes / App health path
    port                = "80"
    protocol            = "HTTP"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
  }

  tags = {
    Name        = "${var.environment}-target-group"
    Environment = var.environment
  }
}

# Listener 1: Port 80 (HTTP) -> Redirects to Port 443 (HTTPS)
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.external_alb.load_balancer_arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listener 2: Port 443 (HTTPS) -> Forwards to target group
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.external_alb.load_balancer_arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06" # Mozilla modern TLS standard
  certificate_arn   = "arn:aws:acm:us-east-1:123456789012:certificate/dummy-cert-arn-uuid"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
