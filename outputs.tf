# Output manager node details
output "manager_nodes" {
  value = [for idx, server in hcloud_server.swarm_managers : {
    name         = server.name
    ipv4_address = server.ipv4_address
    private_ip   = hcloud_server_network.swarm_manager_networks[idx].ip
  }]
  description = "Details of Docker Swarm manager nodes"
}

# Output worker node details
output "worker_nodes" {
  value = [for idx, server in hcloud_server.swarm_workers : {
    name         = server.name
    ipv4_address = server.ipv4_address
    private_ip   = hcloud_server_network.swarm_worker_networks[idx].ip
  }]
  description = "Details of Docker Swarm worker nodes"
}

# Output network information
output "swarm_network" {
  value = {
    name      = hcloud_network.swarm_network.name
    ip_range  = hcloud_network.swarm_network.ip_range
    subnet    = hcloud_network_subnet.swarm_subnet.ip_range
  }
  description = "Docker Swarm network configuration"
}

# Swarm cluster primary manager IP
output "swarm_manager_primary_ip" {
  value       = hcloud_server.swarm_managers[0].ipv4_address
  description = "Primary Swarm manager node IP address"
}

# Portainer URL
output "portainer_url" {
  value       = "http://${hcloud_server.swarm_managers[0].ipv4_address}:9443"
  description = "URL to access Portainer web interface"
}
