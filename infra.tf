resource "tls_private_key" "terrafrom_generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {

  # Name of key: Write the custom name of your key
  key_name = "aws_keys_pairs"

  # Public Key: The public will be generated using the reference of tls_private_key.terrafrom_generated_private_key
  public_key = tls_private_key.terrafrom_generated_private_key.public_key_openssh

  # Store private key :  Generate and save private key(aws_keys_pairs.pem) in current directory
  provisioner "local-exec" {
    command = <<-EOT
       echo '${tls_private_key.terrafrom_generated_private_key.private_key_pem}' > aws_keys_pairs.pem
       chmod 400 aws_keys_pairs.pem
     EOT
  }
}


resource "aws_vpc" "main" {
  cidr_block = var.vpccidr
  tags = {
    Name = var.vpc_name
  }
}

data "aws_availability_zones" "az" {}
resource "aws_subnet" "public_subnets" {
  count             = length(var.public_subnets_cidr)
  cidr_block        = element(var.public_subnets_cidr, count.index)
  vpc_id            = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.az.names[count.index]
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Internet Gateway for VPC ${var.vpc_name}"
  }
}

resource "aws_route_table" "public_subnets_route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
  tags = {
    Name = "Public subnet route table"
  }
}

resource "aws_route_table_association" "public_subnets" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
  route_table_id = aws_route_table.public_subnets_route_table.id
}

resource "aws_security_group" "web" {
  name        = var.aws_security_group_name
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name" = "web"
  }
}

resource "aws_security_group_rule" "webapp_ingress" {
  type                     = "ingress"
  count                    = length(var.webapp_ingress_rules)
  from_port                = var.webapp_ingress_rules[count.index].from_port
  to_port                  = var.webapp_ingress_rules[count.index].to_port
  protocol                 = var.webapp_ingress_rules[count.index].protocol
  source_security_group_id = aws_security_group.load_balancer.id
  description              = var.webapp_ingress_rules[count.index].description
  security_group_id        = aws_security_group.web.id
}
resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  count             = length(var.ssh_ingress_rules)
  from_port         = var.ssh_ingress_rules[count.index].from_port
  to_port           = var.ssh_ingress_rules[count.index].to_port
  protocol          = var.ssh_ingress_rules[count.index].protocol
  cidr_blocks       = [var.ssh_ingress_rules[count.index].cidr_blocks]
  description       = var.ssh_ingress_rules[count.index].description
  security_group_id = aws_security_group.web.id
}
resource "aws_security_group_rule" "http_ingress" {
  type                     = "ingress"
  count                    = length(var.http_ingress_rules)
  from_port                = var.http_ingress_rules[count.index].from_port
  to_port                  = var.http_ingress_rules[count.index].to_port
  protocol                 = var.http_ingress_rules[count.index].protocol
  source_security_group_id = aws_security_group.load_balancer.id
  description              = var.http_ingress_rules[count.index].description
  security_group_id        = aws_security_group.web.id
}
resource "aws_security_group_rule" "https_ingress" {
  type                     = "ingress"
  count                    = length(var.http_ingress_rules)
  from_port                = var.https_ingress_rules[count.index].from_port
  to_port                  = var.https_ingress_rules[count.index].to_port
  protocol                 = var.https_ingress_rules[count.index].protocol
  source_security_group_id = aws_security_group.load_balancer.id
  description              = var.https_ingress_rules[count.index].description
  security_group_id        = aws_security_group.web.id
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  count             = length(var.application_egress_rules)
  from_port         = var.application_egress_rules[count.index].from_port
  to_port           = var.application_egress_rules[count.index].to_port
  protocol          = var.application_egress_rules[count.index].protocol
  cidr_blocks       = [var.application_egress_rules[count.index].cidr_block]
  description       = var.application_egress_rules[count.index].description
  security_group_id = aws_security_group.web.id
}

resource "aws_security_group" "load_balancer" {
  name        = var.aws_security_group_name_load_balancer
  description = "Load Balancer Security Group"
  vpc_id      = aws_vpc.main.id
  tags = {
    "Name" = "load balancer security group"
  }
}
resource "aws_security_group_rule" "load_balancer_ingress" {
  type              = "ingress"
  count             = length(var.load_balancer_ingress_rules)
  from_port         = var.load_balancer_ingress_rules[count.index].from_port
  to_port           = var.load_balancer_ingress_rules[count.index].to_port
  protocol          = var.load_balancer_ingress_rules[count.index].protocol
  cidr_blocks       = [var.load_balancer_ingress_rules[count.index].cidr_block]
  description       = var.load_balancer_ingress_rules[count.index].description
  security_group_id = aws_security_group.load_balancer.id
}
resource "aws_security_group_rule" "load_balancer_egress" {
  type              = "egress"
  count             = length(var.application_egress_rules)
  from_port         = var.application_egress_rules[count.index].from_port
  to_port           = var.application_egress_rules[count.index].to_port
  protocol          = var.application_egress_rules[count.index].protocol
  cidr_blocks       = [var.application_egress_rules[count.index].cidr_block]
  description       = var.application_egress_rules[count.index].description
  security_group_id = aws_security_group.load_balancer.id
}
resource "aws_lb_target_group" "web" {
  name     = var.lb_tg_name
  port     = var.lb_tg_port
  protocol = var.lb_tg_protocol
  vpc_id   = aws_vpc.main.id
  health_check {
    enabled           = var.true
    healthy_threshold = var.lg_tg_health_threshold
    interval          = var.lg_tg_health_interval
    path              = "/"
    port              = var.lb_tg_port
    timeout           = var.lg_tg_health_timeout
  }
}
resource "aws_lb" "web" {
  name               = var.lb_name
  internal           = var.false
  load_balancer_type = var.lb_type
  security_groups    = [aws_security_group.load_balancer.id]
  subnets            = aws_subnet.public_subnets[*].id
}
resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web.arn
  port              = var.lb_listener_port
  protocol          = var.lb_listener_protocol
  certificate_arn   = var.certificate_arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }
}

locals {
  user_data_script = <<EOF
#! /bin/bash
sudo yum install git -y
mkdir mygit
cd mygit/
git init
git clone https://github.com/ShriyaDugyala/deploy.git
cd deploy/
chmod +x docker.sh
bash docker.sh
EOF
}

resource "aws_launch_template" "asg_launch_config" {
  name          = var.asg_launch_config_name
  image_id      = var.ami_id
  instance_type = var.ec2_instance_type
  network_interfaces {
    associate_public_ip_address = var.true
    security_groups             = [aws_security_group.web.id]
  }

  block_device_mappings {
    device_name = var.device_name
    ebs {
      delete_on_termination = var.true
      volume_size           = var.ebs_volume_size
      volume_type           = var.ebs_volume_type
      encrypted             = var.true
    }
  }
  key_name  = "aws_keys_pairs"
  user_data = base64encode(local.user_data_script)

  tags = {
    Name = var.asg_launch_config_name
  }
}
resource "aws_autoscaling_group" "web" {
  desired_capacity    = var.mindes_size
  max_size            = var.max_size
  min_size            = var.mindes_size
  default_cooldown    = var.cooldown_period
  vpc_zone_identifier = aws_subnet.public_subnets[*].id
  launch_template {
    id      = aws_launch_template.asg_launch_config.id
    version = "$Latest"
  }
  target_group_arns = [aws_lb_target_group.web.arn]
  tag {
    key                 = var.asg_app
    value               = var.asg_webapp
    propagate_at_launch = var.true
  }
  tag {
    key                 = var.asg_name
    value               = var.profile
    propagate_at_launch = var.true
  }
}
resource "aws_autoscaling_attachment" "asg_attachment_lb" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  lb_target_group_arn    = aws_lb_target_group.web.arn
}

resource "aws_autoscaling_policy" "high_cpu" {
  name                   = "HighCPU"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.web.name
  cooldown               = var.cooldown_period
  scaling_adjustment     = var.one
}
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "High CPU"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 60
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  alarm_description = "This metric monitors EC2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.high_cpu.arn]
}
resource "aws_autoscaling_policy" "low_cpu" {
  name                   = "LowCPU"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.web.name
  cooldown               = var.cooldown_period
  scaling_adjustment     = var.minusone
}
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "Low CPU"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 40
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web.name
  }
  alarm_description = "This metric monitors EC2 cpu utilization"
  alarm_actions     = [aws_autoscaling_policy.low_cpu.arn]
}

resource "aws_route53_record" "application" {
  zone_id = var.zone_id
  name    = var.record_name
  type    = var.record_type
  alias {
    name                   = aws_lb.web.dns_name
    zone_id                = aws_lb.web.zone_id
    evaluate_target_health = var.true
  }
}




