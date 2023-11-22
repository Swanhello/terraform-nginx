# terraform-nginx

This Repo contains two folders:

--- eks-cluster folder ---

which contains the Terraform code:
1. Create S3 and DynamoDB for Terraform backend
2. Create EKS cluster, and deploy it in Private subnet
3. Create Auto-scaling group and EC2 launch template; add EC2 to EKS cluster as a node
4. Create EKS network, including VPC, Public subnet, Private subnet, Internet Gateway, NAT Gateway, Routing table
5. Create Security Groups for EKS components

--- nginx folder ---

Which contanis:
1. A Yaml file for ngnix deployment and service
2. A Bash script to deploy ngnix in EKS cluster

--- Traffic flow ---

Internet -> Internet Gateway -> Public subnet -> NAT Gateway -> EKS control plane in Private subnet -> EKS nodes -> EKS loadbalancer -> EKS service -> EKS pods
