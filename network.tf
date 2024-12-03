# Create a private network
resource "hcloud_network" "swarm_network" {
  name     = "${var.cluster_name}-network"
  ip_range = "10.0.0.0/16"
}

# Create a network subnet
resource "hcloud_network_subnet" "swarm_subnet" {
  network_id   = hcloud_network.swarm_network.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = "10.0.1.0/24"
}

# SSH Key for accessing the servers
resource "hcloud_ssh_key" "swarm_ssh_key" {
  name       = "${var.cluster_name}-ssh-key"
  public_key = file(var.ssh_public_key_path)
}
