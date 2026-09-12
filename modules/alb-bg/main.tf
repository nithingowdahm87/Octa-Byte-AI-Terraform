resource "aws_lb" "main" {
  name                       = "${var.project_name}-${var.environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.alb_sg_id]
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = var.alb_enable_deletion_protection
  ip_address_type            = "ipv4"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alb"
    Tier = "public"
  })
}

resource "aws_lb_target_group" "blue" {
  name_prefix          = "blue-"
  port                 = var.application_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 30

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-tg-blue" })
}

resource "aws_lb_target_group" "green" {
  name_prefix          = "green-"
  port                 = var.application_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "instance"
  deregistration_delay = 30

  lifecycle {
    create_before_destroy = true
  }

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-tg-green" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = var.enable_https ? "redirect" : "forward"

    dynamic "redirect" {
      for_each = var.enable_https ? [1] : []
      content {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    dynamic "forward" {
      for_each = var.enable_https ? [] : [1]
      content {
        target_group {
          arn    = aws_lb_target_group.blue.arn
          weight = var.blue_weight
        }
        target_group {
          arn    = aws_lb_target_group.green.arn
          weight = var.green_weight
        }
      }
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = var.enable_https ? 1 : 0
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type = "forward"

    forward {
      target_group {
        arn    = aws_lb_target_group.blue.arn
        weight = var.blue_weight
      }
      target_group {
        arn    = aws_lb_target_group.green.arn
        weight = var.green_weight
      }
    }
  }
}
