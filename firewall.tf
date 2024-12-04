# Firewall for Docker Swarm nodes
resource "hcloud_firewall" "swarm_firewall" {
  name = "${var.cluster_name}-firewall"

  # SSH access
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  # Docker Swarm manager ports
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "2377"
    source_ips = [
      hcloud_network.swarm_network.ip_range
    ]
  }

  # Docker communication ports
  dynamic "rule" {
    for_each = ["7946", "4789"]
    content {
      direction = "in"
      protocol  = rule.value == "7946" ? "tcp" : "udp"
      port      = rule.value
      source_ips = [
        hcloud_network.swarm_network.ip_range
      ]
    }
  }

  # Optional: Allow HTTP/HTTPS for potential web services
  dynamic "rule" {
    for_each = ["80", "443"]
    content {
      direction = "in"
      protocol  = "tcp"
      port      = rule.value
      source_ips = [
        "0.0.0.0/0",
        "::/0"
      ]
    }
  }

  # Portainer web interface
  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "9443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}
