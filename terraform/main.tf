provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_default_vpc" "vpc" {}

data "aws_subnet_ids" "subnets" {
  vpc_id = aws_default_vpc.vpc.id
}

resource "aws_autoscaling_group" "hmq-asg" {
  name_prefix         = "hmq-asg-"
  vpc_zone_identifier = data.aws_subnet_ids.subnets.ids
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  load_balancers      = [aws_elb.hmq-elb.id]

  launch_template {
    id      = aws_launch_template.hmq-templ.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "hmq-templ" {
  name_prefix   = "hmq-templ-"
  instance_type = var.instance_type
  image_id      = data.aws_ami.hmq-ami.id
  user_data     = data.template_cloudinit_config.hmq-config.rendered

  vpc_security_group_ids = [ aws_security_group.hmq-sqr-asg.id ]
  iam_instance_profile { arn = aws_iam_instance_profile.hmq-iam-profile.arn }
}

data "template_cloudinit_config" "hmq-config" {
  base64_encode = true
  gzip = true
  part {
    content_type  = "text/x-shellscript"
    content       = templatefile("scripts/hivemq-install.sh", {
      s3_bucket = var.s3_bucket
      region    = var.region
    })
  }
}

data "aws_ami" "hmq-ami" {
  most_recent = true
  owners = ["474125479812"]
  filter {
    name   = "name"
    values = ["HiveMQ 4.3.6"]
  }
}

resource "aws_security_group" "hmq-sqr-asg" {
  name_prefix   = "hmq-sgr-asg-"

  ingress {
    description = "mqtt access"
    from_port   = 1883
    to_port     = 1883
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.vpc.cidr_block]
  }

  ingress {
    description = "internal"
    from_port   = 7800
    to_port     = 7800
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.vpc.cidr_block]
  }

  ingress {
    description = "Control Center"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_instance_profile" "hmq-iam-profile" {
  name_prefix   = "hmq-iam-profile-"
  role          = aws_iam_role.hmq-iam-role.name
}

resource "aws_iam_role_policy_attachment" "hmq-inst_policy_attach" {
  role          = aws_iam_role.hmq-iam-role.name
  policy_arn    = aws_iam_policy.hmq-iam-policy.arn
}

resource "aws_iam_role" "hmq-iam-role" {
  name_prefix        = "hmq-iam-role-"
  path               = "/"
  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [ {
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Principal": { "Service": "ec2.amazonaws.com" }, "Sid": "" } ]
}
ROLE
}

resource "aws_iam_policy" "hmq-iam-policy" {
  name_prefix           = "hmq-iam-policy-"
  policy                = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [ {
    "Effect": "Allow",
    "Action": [ "s3:GetObject", "s3:PutObject", "s3:DeleteObject", "s3:ListBucket" ],
    "Resource": [ "arn:aws:s3:::hivemq-install", "arn:aws:s3:::hivemq-install/*" ]}]
}
POLICY
}
