variable "ENVIRONMENT" {
    type = string
}

variable "AWS_PROFILE" {
 type = string
 default = "default"
}


variable "SUBNET1_TAG" {
  type = string
}

variable "SUBNET2_TAG" {
  type = string
}


variable "DOMAIN_NAME" {
  type = string
}

variable "VPC_NAME" {
  type = string
}

variable "API_SECURITY_GROUP" {
  type = string
}

variable "LB_NAME" {
  type = string
}

variable "ECS_CLUSTER_NAME" {
  type = string
  default = "server-cluster"
}
