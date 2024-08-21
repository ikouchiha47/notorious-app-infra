# Steps

#### Create IAM roles for ECR, ECS etc.

#### Create a VPC

A isolated network by defining the VPC and related components, as we need to create multiple container instances of our application so that the load balancer is able to distribute the requests evenly. 

#### Add Subnets to VPC

Multiple subnets for multiple availability zones.

#### Create IGW and Route Tables

The Interet Gateway, to connect to iternet, and the route tables associate to the EC2 instances.

#### Create Security Groups

Security groups define which ports to expose to and receive from, the internet. They are attached to the VPC

#### Create an ECS Cluster

This cluster will host the EC2 instances allocated using ECS and ASG

#### Create AWS Key Pair

This will be needed to ssh into EC2 instance. This is linked

#### Create EC2 and ECS Definition

- Create the EC2 launch template, with ECS_CLUSTER variable populated to above cluster name.
- Create the ECS task definition, containing image url, resources, open ports etc. like a docker-compose file.

#### Create Load Balancer

Create the ALB and the LB Target groups.
- The ALB associated with subnets and security group
- The ALB Target Listener, listens to exposed public port like 80 or 443
- The ALB Target Group points to the VPC

Via the VPC, the internet request, goes to the subnets via the cluster, and reaches the EC2 instance

#### Create Auto Scalaing Group

Auto scale connected to the subnets and the ECS launch and the Load balancer as target. With the launch template.

#### Create a DNS Zone and Route53 record

for DNS resolution and Route53 has Nameserver records

#### Create ACM Certificates

These are SSL certificates like letsencrypt, managed by AWS, like systemd letsencrypt updater. These are connected to the HTTPS ALB Listener.