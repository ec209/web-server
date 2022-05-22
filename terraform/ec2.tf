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

resource "aws_instance" "web-server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3a.micro"
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id, aws_security_group.allow_http.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  monitoring                  = false
  disable_api_termination     = false
  ebs_optimized               = false
 source_dest_check           = false
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

  tags = {
    Name    = "web-server"
  }
  lifecycle {
    ignore_changes = [
      ami,
    ]
  }
}

resource "aws_lb_target_group_attachment" "webserver" {
  target_group_arn = module.nlb.target_group_arns[0]
  target_id        = aws_instance.web-server.id
  port             = 80
}
