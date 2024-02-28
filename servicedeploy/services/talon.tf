// iam and ssm 

data "aws_iam_instance_profile" "ecs_instance_profile_arn" {
  name = "ecsInstanceProfile"
}

data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

data "aws_security_group" "security_group" {
  name = var.API_SECURITY_GROUP
}

locals {
  ecs_sh_content = templatefile("${path.module}/templates/ecs/ecs.sh", {
    ECS_CLUSTER_NAME = var.ECS_CLUSTER_NAME
  })
}

resource "aws_launch_template" "app_server_launch_configuration" {
  name_prefix = var.APP_NAME
  image_id      = "ami-027a0367928d05f3e"
  instance_type = "t2.micro"
  key_name      = "tf-key-pair"
  vpc_security_group_ids = [data.aws_security_group.security_group.id]


  iam_instance_profile {
    // name = "ecsInstanceRole"
    arn = data.aws_iam_instance_profile.ecs_instance_profile_arn.arn
  }

  user_data = base64encode(local.ecs_sh_content)
}

data "aws_vpc" "vpc" {
  tags = {
      Name = var.VPC_NAME
  }
}
// Talon API Server
resource "aws_lb_target_group" "app_lb_tg" {
    name = var.TARGET_GROUP_NAME
    port = var.APP_PORT
    protocol = "HTTP"
    vpc_id = data.aws_vpc.vpc.id

    health_check {    
      healthy_threshold   = 3    
      unhealthy_threshold = 10    
      timeout             = 10
      interval            = 30    
      path                = "/ping"    
      port                = "3000"
      matcher             = "200-299" 
  }
}


data "aws_lb" "loadbalancer" {
  name = var.LB_NAME
}

data "aws_lb_listener" "https_lb" {
  load_balancer_arn = data.aws_lb.loadbalancer.arn
  port              = 443
}

resource "aws_lb_listener_rule" "app_server_lb" {
  listener_arn = data.aws_lb_listener.https_lb.arn
  priority = 100

  action {
      type = "forward"
      target_group_arn = aws_lb_target_group.app_lb_tg.arn
    }

  condition {
    host_header {
      values = ["mr-notorious.shop"]
    }
  }
}

data "aws_subnet" "subnet1" {
  filter {
      name = "tag:Name"
      values = ["${var.subnet1_tag}"]
    }
}

data "aws_subnet" "subnet2" {
  filter {
      name = "tag:Name"
      values = ["${var.subnet2_tag}"]
    }
}

resource "aws_autoscaling_group" "app_server_ecs_asg" {
  name                = var.ASG_NAME
  vpc_zone_identifier = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
  target_group_arns = [aws_lb_target_group.app_lb_tg.arn]

  launch_template {
    id = aws_launch_template.app_server_launch_configuration.id
    version = "$Latest"
  }

  min_size         = 1
  max_size         = 1
  desired_capacity = 1

  health_check_type         = "EC2"
  
  lifecycle {
    create_before_destroy = true
  }
  
  tag {
    key                 = "Name"
    value               = var.EC2_INSTANCE_TAG
    propagate_at_launch = true
  }

  tag {
   key                 = "AmazonECSManaged"
   value               = true
   propagate_at_launch = true
 }

 tag {
  key = "ForceRedeploy"
  value = 1
   propagate_at_launch = true
 }
}


// Create a auto scaling group which with a variable
// ECS_CLUSTER set to server Cluster

resource "aws_ecs_task_definition" "server_task_definition" {
    family             = var.APP_NAME
    task_role_arn      = data.aws_iam_role.ecsTaskExecutionRole.arn
    execution_role_arn = data.aws_iam_role.ecsTaskExecutionRole.arn

    container_definitions = templatefile("${path.module}/templates/ecs/ecs-task-definition.json", {
      IMAGE: format("%s.dkr.ecr.%s.amazonaws.com/%s", var.AWS_ACCOUNT, var.AWS_REGION, var.APP_VERSION),
      APP_NAME: var.APP_NAME,
      APP_VERSION: var.APP_VERSION,
      DUMMY_VERSION: 2,
      APP_PORT: var.APP_PORT
    })
}

data "aws_ecs_cluster" "selected" {
  cluster_name = var.ECS_CLUSTER_NAME
}

resource "aws_ecs_service" "app_ecs_service" {
    name = var.APP_NAME
    cluster = data.aws_ecs_cluster.selected.id 
    task_definition = aws_ecs_task_definition.server_task_definition.arn
    desired_count = 1


    force_new_deployment = true
    triggers = {
      redeployment = plantimestamp()
  }
}
