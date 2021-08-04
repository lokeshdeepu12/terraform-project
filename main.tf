provider "google" {
  # credentials = file("../secret_key/ets_DevOps_key.json")
  project = "rock-groove-322023"
  region  = "northamerica-northeast1"
  zone  = "northamerica-northeast1-a"
}

# resource "google_storage_bucket" "terraform_bucket" {
#   name = "cloud-build-bucket-123456"
#   location = "US"
#   force_destroy = true
#   project = var.project_id
#   storage_class = "STANDARD"
# }

# resource "google_storage_bucket" "terraform_bucket_artifacts" {
#   name = "cloud-build-bucket-artifacts-1234885"
#   location = "US"
#   force_destroy = true
#   project = var.project_id
#   storage_class = "STANDARD"
# }

# /*
# ==>  VPC Network
# ==> Cluster Subnet
# ==> Network Routing
# ==> Private Service Connection for SQL
# ==> Firewall Rules
# */




# ////////////////////////////////////////////////////////////
# //                      VPC NETWORK
# ///////////////////////////////////////////////////////////
# resource "google_compute_network" "etms-vpc" {
#     name = var.vpc_network_name
#     project  = var.project_id
#     auto_create_subnetworks = "false"  
# }

# ///////////////////////////////////////////////////////////
# //                 Cluster Subnet
# //////////////////////////////////////////////////////////
# resource "google_compute_subnetwork" "etms-cluster" {
#   name          = var.subnet_cluster
#   ip_cidr_range = "10.1.1.0/24"
#   project       = var.project_id
#   region        = var.location
#   network       = google_compute_network.etms-vpc.id
#   private_ip_google_access = true

#   secondary_ip_range {
#    range_name    = var.pod_range
#    ip_cidr_range = var.ip_cidr_range_pod
#   }

#   secondary_ip_range {
#    range_name    = var.service_range
#    ip_cidr_range = var.ip_cidr_range_service
#   }

# }

# ////////////////////////////////////////////////////////////
# //                 NETWORK Routing
# ////////////////////////////////////////////////////////////


# resource "google_compute_route" "etms-route" {
#   name = "etms-devops-route"
#   dest_range  = "0.0.0.0/0"
#   network = google_compute_network.etms-vpc.name
#   next_hop_gateway = "default-internet-gateway"
# }

# resource "google_compute_router" "etms-router" {
#   name    = "etms-devops-router"
#   region  = google_compute_subnetwork.etms-cluster.region
#   network = google_compute_network.etms-vpc.name
# }

# resource "google_compute_router_nat" "nat_router" {
#   name                               = "etms-devops-nat-router"
#   router                             = google_compute_router.etms-router.name
#   region                             = google_compute_router.etms-router.region
#   nat_ip_allocate_option             = "AUTO_ONLY"
#   source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

#   subnetwork {
#     name                    = google_compute_subnetwork.etms-cluster.name
#     source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
#   }

#   log_config {
#     enable = true
#     filter = "ERRORS_ONLY"
#   }
# }

# ////////////////////////////////////////////////////////////
# //                 Private Service Connection for SQL
# ////////////////////////////////////////////////////////////

# //Allocated Ip Ranges For Services
# resource "google_compute_global_address" "sql_private_ip" {
#   name          = "etms-devops-sql-private-ip"
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 16
#   network       = google_compute_network.etms-vpc.id
# }
# //Private Connections to services
# resource "google_service_networking_connection" "etms_service_connection" {
#   network                 = google_compute_network.etms-vpc.id
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.sql_private_ip.name]
# }

# ////////////////////////////////////////////////////////////
# //                 Firewall Rules
# ////////////////////////////////////////////////////////////

# resource "google_compute_firewall" "etms-firewall" {
#   name    = "etms-devops-firewall-rule"
#   network = google_compute_network.etms-vpc.name

#   allow {
#     protocol = "all"
#   }

#   # allow {
#   #   protocol = "tcp"
#   #   ports    = ["80", "8080", "1000-2000"]
#   # }

#   source_ranges = ["0.0.0.0/0",]
# }

# //********************* STATIC ADDRESS

# resource "google_compute_address" "static" {
#   name = "bastion-host"
#   project = var.project_id
#   region = var.cluster_location
# }

# /////////////////////


# resource "google_compute_instance" "bastion_host" {
#   name         = "bastion-host"
#   machine_type = "e2-medium"
#   zone         = var.zone
#   project      = var.project_id

#   boot_disk {
#     initialize_params {
#       image = "debian-cloud/debian-10"
#       size = 30
#     }
#   }
#     tags = ["https-server", "http-server"]

#     metadata_startup_script = file("startup-script")

#   service_account {
#     scopes = ["storage-ro","trace","logging-write","service-management","monitoring-write","service-control"]
#   }

#     allow_stopping_for_update = true
#   network_interface {
#     network = var.vpc_network_name
#     subnetwork = var.subnet_cluster
#     access_config {   
#         nat_ip =  google_compute_address.static.address
#     }
#   }

# }

# output "external_ip" {
#     value =   google_compute_instance.bastion_host. network_interface[0].access_config[0].nat_ip
# }







///////////////////////////////

/////////*************************CLUSTER

# resource "google_container_cluster" "etms_devops_cluster" {
#   name     = var.cluster_name
#   location = var.cluster_location
#   remove_default_node_pool = true
#   initial_node_count  = "1"
#   network = var.vpc_network_name
#   networking_mode = "VPC_NATIVE"

#   subnetwork = var.subnet_cluster
#   enable_shielded_nodes = true


#   private_cluster_config {
#     enable_private_endpoint = true
#     enable_private_nodes = true
#     master_ipv4_cidr_block = "192.168.0.0/28"
#     master_global_access_config {
#     enabled = true
#     }
#   }

#    ip_allocation_policy { 
#      cluster_secondary_range_name = var.pod_range
#      services_secondary_range_name = var.service_range
#    }
  
#   master_authorized_networks_config  {
#       #google_compute_instance.bastion_host. network_interface[0].access_config[0].nat_ip
#    }

#   release_channel {
#     channel = "REGULAR"
#   }
  
#   lifecycle {
#     create_before_destroy = true
#   }

#   workload_identity_config {
#   identity_namespace = "${var.project_id}.svc.id.goog"
#   }

#   datapath_provider = "ADVANCED_DATAPATH"

#   cluster_autoscaling {
#     enabled = true

#   resource_limits {
#       resource_type = "cpu"
#       maximum = 10
#     }
#   resource_limits {
#       resource_type = "memory"
#       maximum = 30
#     }


#   }

#   vertical_pod_autoscaling {
#     enabled = true
#   }

# }

# //NODE POOL

# resource "google_container_node_pool" "etms_devops_nodes" {
#   name       = "test-nodepool-name"
#   location   = var.cluster_location
#   cluster    = google_container_cluster.etms_devops_cluster.name
#   node_count = 1

#   node_config {
#     preemptible  = false
#     machine_type = "e2-medium"

#     service_account = "default"
    
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
#   lifecycle {
#     create_before_destroy = true
#   }

#   management {
#     auto_repair = true
#     auto_upgrade = true
#   }

#   autoscaling {
#     min_node_count = 1
#     max_node_count = 60
#   }

# }




