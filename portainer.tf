# Deploy Portainer on the Swarm cluster
resource "null_resource" "deploy_portainer" {
  depends_on = [null_resource.swarm_init]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.ssh_private_key_path)
    host        = hcloud_server.swarm_managers[0].ipv4_address
  }

  provisioner "remote-exec" {
    inline = [
      # Create Portainer volume
      "docker volume create portainer_data",
      
      # Deploy Portainer as a Swarm service
      <<-EOT
      docker service create \
        --name portainer \
        --publish 9000:9000 \
        --publish 8000:8000 \
        --constraint 'node.role == manager' \
        --mount type=bind,src=//var/run/docker.sock,dst=/var/run/docker.sock \
        --mount type=volume,src=portainer_data,dst=/data \
        --replicas=1 \
        portainer/portainer-ce:latest \
        -H unix:///var/run/docker.sock
      EOT
    ]
  }
}
