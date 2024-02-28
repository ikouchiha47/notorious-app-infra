resource "aws_route53_zone" "dns_service" {
 name = var.DOMAIN_NAME
}

output "domain_name" {
  value = "${var.DOMAIN_NAME}"
}

// create certificates
resource "aws_acm_certificate" "server_cert" {
  domain_name               = var.DOMAIN_NAME
  subject_alternative_names = ["*.${var.DOMAIN_NAME}"]
  validation_method         = "DNS"

  tags = {
    Environment = var.ENVIRONMENT
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_route53_record" "dns_record_validation" {
  for_each = {
    for dvo in aws_acm_certificate.server_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.dns_service.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [
    each.value.record,
  ]

  allow_overwrite = true
}

resource "aws_acm_certificate_validation" "server_cert_validator" {
  certificate_arn         = aws_acm_certificate.server_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.dns_record_validation : record.fqdn]
}


// Create vpc and add a subnet
// Add a routing table and direct all traffic from internet
// to the subnet
resource "aws_vpc" "private_vpc" {
  cidr_block = "10.0.0.0/20"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags       = {
      Name = var.VPC_NAME
  }
}

resource "aws_internet_gateway" "private_vpc_ig" {
  vpc_id = aws_vpc.private_vpc.id
}

resource "aws_route_table" "vpc_rt" {
  vpc_id =  aws_vpc.private_vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.private_vpc_ig.id
    }
}

resource "aws_subnet" "server_subnet" {
    vpc_id                  = aws_vpc.private_vpc.id
    cidr_block              = cidrsubnet(aws_vpc.private_vpc.cidr_block, 8, 1)
    map_public_ip_on_launch = true
    availability_zone       = "ap-south-1b"

    tags = {
      Name = "${var.SUBNET1_TAG}"
    }
}

resource "aws_subnet" "server_subnet2" {
    vpc_id                  = aws_vpc.private_vpc.id
    cidr_block              = cidrsubnet(aws_vpc.private_vpc.cidr_block, 8, 2)
    map_public_ip_on_launch = true
    availability_zone       = "ap-south-1a"

    tags = {
      Name = "${var.SUBNET2_TAG}"
    }
}


resource "aws_route_table_association" "subnet1_server_route" {
  route_table_id = aws_route_table.vpc_rt.id
  subnet_id = aws_subnet.server_subnet.id
}

resource "aws_route_table_association" "subnet2_server_route" {
  route_table_id = aws_route_table.vpc_rt.id
  subnet_id = aws_subnet.server_subnet2.id
}

resource "aws_security_group" "api_sg" {
  name = var.API_SECURITY_GROUP
  vpc_id = aws_vpc.private_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "tf-key-pair" {
  key_name = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair.pem"
}

resource "aws_lb" "app_lb" {
  name               = var.LB_NAME
  internal           = false
  load_balancer_type = "application"

  preserve_host_header = true
  
  security_groups = [aws_security_group.api_sg.id]
  subnets         = [aws_subnet.server_subnet.id, aws_subnet.server_subnet2.id]

  enable_deletion_protection = false

  tags = {
      Environment = var.ENVIRONMENT
      Name = "ServerLoadBalancer"
    }
}



resource "aws_route53_record" "server_route_alias" {
  zone_id = aws_route53_zone.dns_service.zone_id
  name    = "${aws_route53_zone.dns_service.name}"
  type    = "A"

  alias {
    name                   = aws_lb.app_lb.dns_name
    zone_id                = aws_lb.app_lb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_lb_listener" "ssl_lb_listener" {
    load_balancer_arn = aws_lb.app_lb.arn
    port = "443"
    protocol = "HTTPS"
    certificate_arn   = aws_acm_certificate.server_cert.arn
    ssl_policy = "ELBSecurityPolicy-2016-08"

    depends_on = [ aws_acm_certificate_validation.server_cert_validator ]

    default_action {
      type = "fixed-response"
 
      fixed_response {
       content_type = "text/plain"
       message_body = "HEALTHY"
       status_code  = "200"
     }
    }
}

resource "aws_ecs_cluster" "server_cluster" {
  name = var.ECS_CLUSTER_NAME
}

output "server_subnet_id" {
    value = aws_subnet.server_subnet.id
}

output "server_subnet2_id" {
    value = aws_subnet.server_subnet2.id
}

output "aws_vpc_id" {
    value = aws_vpc.private_vpc.id
}

output "aws_lb_listener_arn" {
    value = aws_lb_listener.ssl_lb_listener.arn
}

output "aws_cluster_id" {
    value = aws_ecs_cluster.server_cluster.id
}

output "api_security_group_id" {
  value = aws_security_group.api_sg.id
}
