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

variable "manager_server_type" {
  description = "Server type for manager nodes"
  type        = string
  default     = "cx22"
}

variable "worker_server_type" {
  description = "Server type for worker nodes"
  type        = string
  default     = "cx22"
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

variable "portainer_password" {
  description = "Admin password for Portainer"
  type        = string
  sensitive   = true
}

variable "csi_plugin_version" {
  description = "Version of the Hetzner CSI plugin to install"
  type        = string
  default     = "latest"
}
