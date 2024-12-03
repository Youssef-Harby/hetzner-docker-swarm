variable "hcloud_token" {
  description = "Hetzner Cloud API token"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name prefix for the cluster resources"
  type        = string
  default     = "docker-swarm"
}

variable "location" {
  description = "Hetzner Cloud location"
  type        = string
  default     = "nbg1"  # Nuremberg, Germany
}

variable "manager_count" {
  description = "Number of Docker Swarm manager nodes"
  type        = number
  default     = 3
}

variable "worker_count" {
  description = "Number of Docker Swarm worker nodes"
  type        = number
  default     = 2
}

variable "server_type" {
  description = "Hetzner server type for nodes"
  type        = string
  default     = "cx22"  # 2 vCPU, 4GB RAM
}

variable "os_image" {
  description = "Operating system image"
  type        = string
  default     = "ubuntu-24.04"
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key"
  type        = string
}

variable "ssh_private_key_path" {
  description = "Path to the SSH private key"
  type        = string
}

variable "network_zone" {
  description = "Hetzner network zone"
  type        = string
  default     = "eu-central"
}
