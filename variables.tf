variable "vpc_name" {
  type    = string
  default = "vpc1"
}
variable "vpccidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR Block"
  validation {
    condition     = contains(["10.0.0.0/16", "192.168.0.0/16", "172.31.0.0/16"], var.vpccidr)
    error_message = "Please enter a valid CIDR. Allowed values are 10.0.0.0/16, 192.168.0.0/16 and 172.31.0.0/16"
  }
}
variable "public_subnets_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  description = "Public subnets for VPC"
}

variable "webapp_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    description = string
  }))
  default = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "web"
    }
  ]
}
variable "ssh_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
    description = string
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "SSH"
    }
  ]
}
variable "http_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
    description = string
  }))
  default = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTP"
    }
  ]
}
variable "https_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = string
    description = string
  }))
  default = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "HTTPS"
    }
  ]
}
variable "application_egress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_block  = "0.0.0.0/0"
      description = "Allow Outbound Traffic"
    },
  ]
}
variable "aws_security_group_name" {
  type    = string
  default = "web"
}

variable "true" {
  type    = bool
  default = "true"
}
variable "false" {
  type    = bool
  default = "false"
}


variable "aws_security_group_name_load_balancer" {
  type    = string
  default = "load balancer"
}
variable "load_balancer_ingress_rules" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
  default = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
      description = "HTTPS"
    }
  ]
}
variable "lb_tg_protocol" {
  type    = string
  default = "HTTP"
}
variable "lb_tg_name" {
  type    = string
  default = "web-lb-tg"
}
variable "lb_tg_port" {
  type    = number
  default = 80
}
variable "lg_tg_health_threshold" {
  type    = number
  default = 2
}
variable "lg_tg_health_interval" {
  type    = number
  default = 60
}
variable "lg_tg_health_timeout" {
  type    = number
  default = 30
}
variable "lb_name" {
  type    = string
  default = "web"
}
variable "lb_type" {
  type    = string
  default = "application"
}
variable "lb_listener_port" {
  type    = number
  default = 443
}
variable "lb_listener_protocol" {
  type    = string
  default = "HTTPS"
}

variable "asg_launch_config_name" {
  type    = string
  default = "asg_launch_config"
}
variable "device_name" {
  type    = string
  default = "/dev/xvda"
}
variable "max_size" {
  type    = number
  default = 5
}
variable "mindes_size" {
  type    = number
  default = 3
}
variable "cooldown_period" {
  type    = number
  default = 60
}
variable "asg_app" {
  type    = string
  default = "web"
}
variable "asg_webapp" {
  type    = string
  default = "Webapp"
}
variable "asg_name" {
  type    = string
  default = "Name"
}
variable "name" {
  type    = string
  default = "web"
}

variable "profile" {
  type        = string
  default     = "aws-terraform"
  description = "Account in which the resources will be deployed"
}
variable "region" {
  type        = string
  default     = "us-east-1"
  description = "Region where the resources will be deployed"
}

variable "ami_id" {
  type        = string
  default     = "ami-08a52ddb321b32a8c"
  description = "AWS AMI ID"
}

variable "ec2_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 Instance Type"
}

variable "ebs_volume_size" {
  type        = string
  default     = 20
  description = "EBS Volume Size"
}
variable "ebs_volume_type" {
  type        = string
  default     = "gp2"
  description = "EBS Volume Type"
}

variable "one" {
  type    = number
  default = 1
}
variable "minusone" {
  type    = number
  default = -1
}


variable "certificate_arn" {
  type    = string
  default = "arn:aws:acm:us-east-1:110394339693:certificate/1e631963-5e20-471f-bc97-01267a87657d"
}


variable "zone_id" {
  type    = string
  default = "Z0025441ZR1PCYI5EJVS"
}
variable "record_name" {
  type    = string
  default = "gowthm4531.lol"
}
variable "record_type" {
  type    = string
  default = "A"
}
