# Manager Nodes
resource "hcloud_server" "swarm_managers" {
  count       = var.manager_count
  name        = "${var.cluster_name}-manager-${count.index + 1}"
  server_type = var.server_type
  location    = var.location
  image       = var.os_image
  ssh_keys    = [hcloud_ssh_key.swarm_ssh_key.id]
  firewall_ids = [hcloud_firewall.swarm_firewall.id]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Remove old versions
      "for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg || true; done",
      
      # Install prerequisites
      "apt-get update",
      "apt-get install -y ca-certificates curl",
      "install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "chmod a+r /etc/apt/keyrings/docker.asc",
      
      # Add Docker repository
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      
      # Update apt and install Docker
      "apt-get update",
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      
      # Start and enable Docker
      "systemctl enable docker",
      "systemctl start docker"
    ]
  }
}

# Manager Network Attachments
resource "hcloud_server_network" "swarm_manager_networks" {
  count      = var.manager_count
  server_id  = hcloud_server.swarm_managers[count.index].id
  network_id = hcloud_network.swarm_network.id
  ip         = "10.0.1.${10 + count.index}"
  depends_on = [hcloud_network_subnet.swarm_subnet]
}

# Worker Nodes
resource "hcloud_server" "swarm_workers" {
  count       = var.worker_count
  name        = "${var.cluster_name}-worker-${count.index + 1}"
  server_type = var.server_type
  location    = var.location
  image       = var.os_image
  ssh_keys    = [hcloud_ssh_key.swarm_ssh_key.id]
  firewall_ids = [hcloud_firewall.swarm_firewall.id]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = self.ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Remove old versions
      "for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove -y $pkg || true; done",
      
      # Install prerequisites
      "apt-get update",
      "apt-get install -y ca-certificates curl",
      "install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
      "chmod a+r /etc/apt/keyrings/docker.asc",
      
      # Add Docker repository
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      
      # Update apt and install Docker
      "apt-get update",
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      
      # Start and enable Docker
      "systemctl enable docker",
      "systemctl start docker"
    ]
  }
}

# Worker Network Attachments
resource "hcloud_server_network" "swarm_worker_networks" {
  count      = var.worker_count
  server_id  = hcloud_server.swarm_workers[count.index].id
  network_id = hcloud_network.swarm_network.id
  ip         = "10.0.1.${20 + count.index}"
  depends_on = [hcloud_network_subnet.swarm_subnet]
}

# Docker Swarm Initialization
resource "null_resource" "swarm_init" {
  depends_on = [
    hcloud_server_network.swarm_manager_networks,
    hcloud_server_network.swarm_worker_networks
  ]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = hcloud_server.swarm_managers[0].ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for Docker to be ready
      "while ! docker info > /dev/null 2>&1; do sleep 1; done",
      # Initialize Swarm with private IP
      "docker swarm init --advertise-addr ${hcloud_server_network.swarm_manager_networks[0].ip}",
      # Save join tokens
      "docker swarm join-token manager -q > /root/manager-token",
      "docker swarm join-token worker -q > /root/worker-token"
    ]
  }
}

# Join additional manager nodes
resource "null_resource" "additional_managers" {
  count = var.manager_count > 1 ? var.manager_count - 1 : 0
  depends_on = [null_resource.swarm_init]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = hcloud_server.swarm_managers[count.index + 1].ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for Docker to be ready
      "while ! docker info > /dev/null 2>&1; do sleep 1; done",
      # Get manager token and join the swarm using private IP
      "TOKEN=$(ssh -o StrictHostKeyChecking=no -i ${var.ssh_private_key_path} root@${hcloud_server.swarm_managers[0].ipv4_address} 'cat /root/manager-token')",
      "docker swarm join --token $TOKEN ${hcloud_server_network.swarm_manager_networks[0].ip}:2377"
    ]
  }
}

# Join worker nodes
resource "null_resource" "swarm_workers" {
  count = var.worker_count
  depends_on = [null_resource.swarm_init]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = hcloud_server.swarm_workers[count.index].ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Wait for Docker to be ready
      "while ! docker info > /dev/null 2>&1; do sleep 1; done",
      # Create .ssh directory and copy private key
      "mkdir -p ~/.ssh",
      "echo '${file(var.ssh_private_key_path)}' > ~/.ssh/swarm_key",
      "chmod 600 ~/.ssh/swarm_key",
      # Get worker token and join the swarm using private IP
      "TOKEN=$(ssh -o StrictHostKeyChecking=no -i ~/.ssh/swarm_key root@${hcloud_server.swarm_managers[0].ipv4_address} 'cat /root/worker-token')",
      "docker swarm join --token $TOKEN ${hcloud_server_network.swarm_manager_networks[0].ip}:2377",
      # Clean up
      "rm ~/.ssh/swarm_key"
    ]
  }
}
