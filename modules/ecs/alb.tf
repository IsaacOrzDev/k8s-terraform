resource "aws_default_vpc" "default_vpc" {
}


resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-west-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-west-1b"
}

resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-dev"
  load_balancer_type = "application"
  subnets = [
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}"
  ]

  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_route53_record" "api" {
  name    = "${var.sub_domain_name}.${var.domain_name}"
  type    = "A"
  zone_id = data.aws_route53_zone.public.zone_id

  alias {
    name                   = aws_alb.application_load_balancer.dns_name
    zone_id                = aws_alb.application_load_balancer.zone_id
    evaluate_target_health = false
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn #  load balancer
  port              = "80"
  protocol          = "HTTP"
  default_action {
    # if https is not enabled
    # type             = "forward"
    # target_group_arn = aws_lb_target_group.target_group.arn # target group

    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# if https is enabled
resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.api.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

output "alb_default_url" {
  value = "http://${aws_alb.application_load_balancer.dns_name}"
}
