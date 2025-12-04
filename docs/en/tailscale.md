# Tailscale Mesh Network

Tailscale creates a secure mesh network (VPN) between your devices and infrastructure using WireGuard protocol. It's perfect for connecting your development machines, CI/CD runners, and cloud resources.

## Features

- **Zero-config VPN**: Automatic peer discovery and connection
- **End-to-end encryption**: Using WireGuard protocol
- **Cross-platform**: Works on Linux, Windows, macOS, iOS, Android
- **ACLs**: Fine-grained access control
- **MagicDNS**: Automatic DNS resolution for devices
- **Subnet routing**: Access to entire networks through exit nodes

## Installation

### Linux (Ubuntu/Debian)

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

### macOS

```bash
brew install tailscale
```

### Windows

Download and install from [tailscale.com/download](https://tailscale.com/download)

## Quick Start

### 1. Authenticate

```bash
sudo tailscale up
```

This will open a browser window for authentication. After logging in, your device will join your tailnet.

### 2. Check Status

```bash
tailscale status
```

### 3. Get Your IP

```bash
tailscale ip -4
```

## Infrastructure Integration

### Using with Terraform

```hcl
resource "tailscale_tailnet_key" "ci_cd" {
  reusable      = true
  ephemeral     = false
  preauthorized = true
  expiry        = 7776000  # 90 days
  description   = "CI/CD authentication key"
}

output "tailscale_key" {
  value     = tailscale_tailnet_key.ci_cd.key
  sensitive = true
}
```

### GitHub Actions Integration

```yaml
- name: Connect to Tailscale
  uses: tailscale/github-action@v2
  with:
    oauth-client-id: ${{ secrets.TS_OAUTH_CLIENT_ID }}
    oauth-secret: ${{ secrets.TS_OAUTH_SECRET }}
    tags: tag:ci

- name: Access internal resources
  run: |
    curl http://internal-service.tail-scale.ts.net
```

### Subnet Routing

To expose an entire subnet through a Tailscale node:

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p /etc/sysctl.conf

sudo tailscale up --advertise-routes=10.0.0.0/24
```

Then approve the routes in the Tailscale admin console.

## Access Control Lists (ACLs)

Example ACL configuration:

```json
{
  "acls": [
    {
      "action": "accept",
      "src": ["tag:ci"],
      "dst": ["tag:production:*"]
    },
    {
      "action": "accept",
      "src": ["group:developers"],
      "dst": ["tag:development:*"]
    }
  ],
  "tagOwners": {
    "tag:ci": ["autogroup:admin"],
    "tag:production": ["autogroup:admin"],
    "tag:development": ["autogroup:admin"]
  }
}
```

## MagicDNS

Enable MagicDNS in your tailnet settings to use hostnames instead of IPs:

```bash
# Instead of:
ssh 100.64.1.2

# Use:
ssh my-server.tail-scale.ts.net
```

## Best Practices

1. **Use tags** for infrastructure nodes instead of user accounts
2. **Enable MagicDNS** for easier service discovery
3. **Set up subnet routing** for accessing entire networks
4. **Use ACLs** to restrict access between different environments
5. **Rotate auth keys** regularly for CI/CD
6. **Enable HTTPS** for Tailscale admin console access

## Troubleshooting

### Connection Issues

```bash
# Check connectivity
tailscale ping <device-name>

# View detailed status
tailscale status --json

# Check logs
sudo journalctl -u tailscaled
```

### Reset Connection

```bash
sudo tailscale down
sudo tailscale up
```

## Resources

- [Official Documentation](https://tailscale.com/kb/)
- [Terraform Provider](https://registry.terraform.io/providers/tailscale/tailscale/latest/docs)
- [GitHub Action](https://github.com/tailscale/github-action)
