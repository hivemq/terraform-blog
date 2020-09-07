resource "aws_elb" "hmq-elb" {
  name = "hmq-elb"
  subnets = data.aws_subnet_ids.subnets.ids
  security_groups = [aws_security_group.sqr-hmq-elb.id]

  listener {
    instance_port     = "1883"
    instance_protocol = "tcp"
    lb_port           = "1883"
    lb_protocol       = "tcp"
  }
  listener {
    instance_port     = "8080"
    instance_protocol = "http"
    lb_port           = "8080"
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "tcp:1883"
    interval            = 10
  }
  idle_timeout                = "600"
  connection_draining         = "true"
}

resource "aws_lb_cookie_stickiness_policy" "cc-policy" {
  name                     = "cc-policy"
  load_balancer            = aws_elb.hmq-elb.id
  lb_port                  = 8080
  cookie_expiration_period = 3600
}

resource "aws_security_group" "sqr-hmq-elb" {
  name_prefix = "sqr-hmq-elb-"
  vpc_id      = aws_default_vpc.vpc.id

  # mqtt traffic To LB
  ingress {
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = var.restricted_cidr
  }

  # ControlCenter access
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.restricted_cidr
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}