# EC2 Compute resources (Launch Template, ASG, Scaling Policies)

# Fetch latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template for Auto Scaling Instances
resource "aws_launch_template" "app_launch_template" {
  name_prefix   = "${var.environment}-app-template-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.compute_instance_type

  # Network Interface
  network_interfaces {
    associate_public_ip_address = false # Deploy in private subnets
    security_groups             = [aws_security_group.compute_sg.id]
  }

  # Root disk volume details
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = 50
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # Startup Script (Installs Docker & System configurations)
  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Starting App Host Bootstrapping..."
              yum update -y
              # Install Docker
              amazon-linux-extras install docker -y
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              
              # Health check status confirmation file
              mkdir -p /var/www/html
              echo "OK" > /var/www/html/healthz
              
              # Minimal health check server on port 80 (Simulated app status indicator)
              docker run -d --name status-chk -p 80:80 -v /var/www/html:/usr/share/nginx/html nginx:alpine
              echo "Bootstrapping Completed successfully."
              EOF
  )

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.environment}-app-host"
      Environment = var.environment
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group in Private Subnets
resource "aws_autoscaling_group" "app_asg" {
  name_prefix         = "${var.environment}-app-asg-"
  desired_capacity    = 3
  max_size            = 6
  min_size            = 2
  vpc_zone_identifier = [for s in aws_subnet.private : s.id]
  target_group_arns   = [aws_lb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_launch_template.id
    version = "$Latest"
  }

  # Health Check Type: Link directly to ALB health checks
  health_check_type         = "ELB"
  health_check_grace_period = 300

  force_delete          = false
  suspended_processes   = []
  enabled_metrics       = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]

  tag {
    key                 = "Name"
    value               = "${var.environment}-asg-instance"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Policy: Scale based on CPU Utilization
resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${var.environment}-asg-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.app_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0 # Scale out when average CPU exceeds 75%
  }
}
