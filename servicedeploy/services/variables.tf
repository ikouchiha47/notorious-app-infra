variable "APP_NAME" {
  type  = string
}

variable "AWS_REGION" {
  type = string
}

variable "AWS_PROFILE" {
  type = string
}

variable "AWS_ACCOUNT" {
  type = string
}

variable "ENVIRONMENT" {
    type = string
    default = "production"
}

variable "APP_VERSION" {
  type = string
  default = "notorious:latest"
}

variable "VPC_NAME" {
  type = string
}

variable "API_SECURITY_GROUP" {
  type = string
}

variable APP_PORT {
  type = number
  default = 3000
}

variable LB_NAME {
  type = string
  default = "app-server-lb"
}

variable "TARGET_GROUP_NAME" {
  type = string
  default = "NotoriousServerTgHttp"
}

variable "ASG_NAME" {
  type = string
  default = "AppServerAsg"
}

variable "EC2_INSTANCE_TAG" {
  type = string
  default = "AppServerInstance"
} 

variable "ECS_CLUSTER_NAME" {
  type = string
}

variable "subnet1_tag" {
  type = string
  default = "notorious-subnet-zone-b"
}

variable "subnet2_tag" {
  type = string
  default = "notorious-subnet-zone-a"
}
