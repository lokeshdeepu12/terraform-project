variable "cluster_name" {
    default = "test-cluster"
}
variable "cluster_location" {
    default = "northamerica-northeast1"
}
variable "zone" {
    default = "northamerica-northeast1-a" 
}
variable "project_id" {
    default = "my-new-project-test-320513"
}
variable "location" {
    default = "northamerica-northeast1"
}
//************ VPC NETWORK

//***************** VPC-Network
variable "vpc_network_name" {
  default = "etms-devops-vpc-network"
}

//Subnet-Cluster
variable "subnet_cluster" {
  default = "etms-devops-cluster-subnet"
}
//Subnet-Sql Instance
variable "subnet_sql_instance" {
  default = "etms-devops-sql-instance-subnet"
}

//Secondary IP range PODS
variable "pod_range" {
  default = "etms-devops-cluster-pod-range"
}
//IP_CIDR_RANGE POD
variable "ip_cidr_range_pod" {
  default = "10.92.0.0/14"
}
//Secondary IP range Services
variable "service_range" {
  default = "etms-devops-cluster-service-range"
}
//IP_CIDR_RANGE Service 
variable "ip_cidr_range_service" {
  default = "10.96.0.0/20"
}