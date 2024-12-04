# Install Hetzner Cloud CSI Driver on all manager nodes
resource "null_resource" "setup_hcloud_csi" {
  count = var.manager_count

  triggers = {
    server_id = hcloud_server.swarm_managers[count.index].id
    plugin_version = var.csi_plugin_version
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = hcloud_server.swarm_managers[count.index].ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Install Hetzner Cloud CSI Driver
      "docker plugin install --disable --alias hetznercloud/hcloud-csi-driver:${var.csi_plugin_version}-swarm --grant-all-permissions hetznercloud/hcloud-csi-driver:${var.csi_plugin_version}-swarm || true",
      "docker plugin set hetznercloud/hcloud-csi-driver:${var.csi_plugin_version}-swarm HCLOUD_TOKEN=${var.hcloud_token}",
      "docker plugin enable hetznercloud/hcloud-csi-driver:${var.csi_plugin_version}-swarm",
    ]
  }
}

# Deploy Portainer on the Swarm cluster
resource "null_resource" "deploy_portainer" {
  depends_on = [null_resource.setup_hcloud_csi]

  triggers = {
    stack_sha1 = sha1(file("${path.module}/portainer-stack.yml"))
  }

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = hcloud_server.swarm_managers[0].ipv4_address
  }

  # Copy stack file
  provisioner "file" {
    source      = "${path.module}/portainer-stack.yml"
    destination = "/root/portainer-stack.yml"
  }

  # Setup and deploy
  provisioner "remote-exec" {
    inline = [
      # Create secrets directory and password file
      "mkdir -p /root/secrets",
      "echo '${var.portainer_password}' > /root/secrets/portainer-password.txt",
      
      # Create overlay network if it doesn't exist
      "echo 'Creating overlay network...'",
      "docker network create --driver overlay --attachable swarm-net || true",

      # Remove existing stack if any
      "echo 'Removing existing Portainer stack...'",
      "docker stack rm portainer || true",
      "sleep 10", # Wait for stack to be removed

      # Deploy new stack
      "echo 'Deploying new Portainer stack...'",
      "docker stack deploy -c /root/portainer-stack.yml portainer",

      # Wait for service to be ready
      "echo 'Waiting for Portainer to start...'",
      "timeout 60 bash -c 'until docker service ls | grep -q \"portainer_portainer.*1/1.*running\"; do sleep 2; done'",
      
      # Verify deployment
      "docker service ls | grep portainer_portainer",
      "curl -s -o /dev/null -w \"%%{http_code}\" http://localhost:9443 || true"
    ]
  }
}
