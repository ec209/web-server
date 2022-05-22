data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["ubuntu*"]
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow http inbound traffic from NLB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Public HTTP connections"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_launch_configuration" "web-server" {
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t3a.micro"
  security_groups             = [aws_security_group.allow_http.id,]
  associate_public_ip_address = true
  ebs_optimized               = false
  root_block_device {
    volume_type = "gp2"
    volume_size = 10
    encrypted   = true
  }
  key_name                    = "ec209"
  user_data                   = <<EOF
#!/bin/bash -xe
apt install -y nginx
cat > /var/www/html/index.nginx-debian.html << EOD
<!DOCTYPE html>
<html>
<head>
<title>Cisco SPL</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Cisco SPL</h1>
</body>
</html>
EOD
EOF

  lifecycle {
    ignore_changes = [
      image_id,
    ]
  }
}

resource "aws_autoscaling_group" "web-server" {
  name                 = "web-server"
  launch_configuration = aws_launch_configuration.web-server.name
  vpc_zone_identifier  = [module.vpc.private_subnets[0],]
  min_size             = 1
  max_size             = 2
  target_group_arns    = module.nlb.target_group_arns

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "web-server" {
  name                   = "web-server"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.web-server.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}
