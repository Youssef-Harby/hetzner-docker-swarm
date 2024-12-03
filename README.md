# Hetzner Docker Swarm Terraform Deployment

## Overview
This Terraform configuration creates a scalable Docker Swarm cluster on Hetzner Cloud, with configurable number of manager and worker nodes.

## Prerequisites
- Hetzner Cloud Account
- Terraform (>= 1.0)
- Hetzner Cloud API Token
- SSH Key Pair

## Configuration

### Variables
Customize the deployment by modifying `variables.tf`:
- `hcloud_token`: Hetzner Cloud API token (required)
- `cluster_name`: Prefix for cluster resources (default: "docker-swarm")
- `location`: Hetzner Cloud location (default: "fsn1")
- `manager_count`: Number of manager nodes (default: 3)
- `worker_count`: Number of worker nodes (default: 2)
- `server_type`: Server type (default: "cx22")
- `ssh_public_key_path`: Path to SSH public key
- `ssh_private_key_path`: Path to SSH private key

### Deployment Steps
1. Clone this repository
2. Create a `terraform.tfvars` file:
```hcl
hcloud_token         = "your_hetzner_cloud_token"
ssh_public_key_path  = "/path/to/your/public/key.pub"
ssh_private_key_path = "/path/to/your/private/key"
```

3. Initialize Terraform:
```bash
terraform init
```

4. Plan the deployment:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

## Features
- Configurable number of manager and worker nodes
- Private network configuration
- Firewall rules for Docker Swarm
- Automatic Docker Swarm initialization
- Portainer for cluster management
- Outputs for cluster information

## Accessing Portainer
After deployment, Portainer will be available at `http://<manager-node-ip>:9000`. 

1. On first access, create an admin user
2. Choose "Docker Swarm" environment
3. Portainer will automatically connect to your Swarm cluster

You can find the Portainer URL in the Terraform outputs after deployment.

## Scaling
Modify `manager_count` and `worker_count` variables to scale your cluster.

## Security Considerations
- Use strong, unique SSH keys
- Protect your Hetzner Cloud API token
- Review and customize firewall rules

## Cleanup
To destroy the infrastructure:
```bash
terraform destroy
```

## Troubleshooting
- Ensure API token has correct permissions
- Check network and firewall configurations
- Verify SSH key paths

## License
MIT License
