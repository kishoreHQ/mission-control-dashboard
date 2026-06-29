# Tailscale Setup Guide

## What is Tailscale?

Tailscale creates a secure private network (VPN) between your devices using WireGuard. It allows you to:
- Access your VPS from anywhere without opening firewall ports
- SSH into your VPS using a stable hostname instead of IP
- Connect the dashboard to VPS securely

## Your Current Setup (VPS)

Your VPS already has Tailscale installed and running:

```bash
# Check status (run on VPS)
tailscale status
# Should show: connected, with IP like 100.x.x.x

# Get your VPS Tailscale IP
tailscale ip -4
# Example: 100.64.123.45
```

## Your Local Machine Setup (Mac)

### Step 1: Install Tailscale

```bash
# Using Homebrew
brew install tailscale

# Or download from: https://tailscale.com/download
```

### Step 2: Start Tailscale

```bash
# Start the daemon
sudo tailscaled

# In another terminal, authenticate
tailscale up
# This will open a browser to authenticate with your Tailscale account
```

### Step 3: Verify Connection

```bash
# See your devices
tailscale status

# Should show both your Mac and VPS
# Example:
# 100.64.123.45  vps-hermes       kishore@      linux   -
# 100.64.67.89   kishores-macbook kishore@      macOS   -
```

### Step 4: Test SSH to VPS

```bash
# SSH via Tailscale (no password needed if SSH key set up)
ssh root@100.64.123.45

# Or use Tailscale's built-in SSH
tailscale ssh root@vps-hermes
```

## Dashboard Connection Modes

### Mode A: Dashboard Runs ON VPS (Recommended)

```bash
# On VPS:
cd /root/mission-control-dashboard
npm run dev -- --host 0.0.0.0

# On your Mac, open browser:
http://100.64.123.45:5173
```

**Pros:** Fastest, no SSH overhead, direct file access  
**Cons:** Need to be on Tailscale to access

### Mode B: Dashboard Runs ON Mac (Development)

```bash
# On your Mac:
cd mission-control-dashboard
npm run dev

# Dashboard needs to fetch data from VPS via SSH
```

**Pros:** Local development, fast reloads  
**Cons:** Need SSH connection, more complex data fetching

### Mode C: Build and Serve Statically

```bash
# Build on VPS or Mac
npm run build

# Serve dist/ folder with nginx or any static server
# On VPS:
cp -r dist/ /var/www/mission-control/

# Access via: http://100.64.123.45:80
```

**Pros:** Fastest runtime, no Node.js needed for serving  
**Cons:** Need to rebuild for updates

## Tailscale ACL (Access Control)

If you want to restrict who can access the dashboard:

```json
// tailscale ACL (configured in Tailscale admin console)
{
  "acls": [
    {
      "action": "accept",
      "src": ["kishore@"],
      "dst": ["tag:hermes-vps:5173"],
      "proto": "tcp"
    }
  ],
  "tagOwners": {
    "tag:hermes-vps": ["kishore@"]
  }
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Can't connect to VPS | Check Tailscale status on both sides |
| SSH fails | Verify SSH key is added to VPS: `cat ~/.ssh/authorized_keys` |
| Slow connection | Check if using DERP relay: `tailscale status` (look for "relay") |
| Dashboard not loading | Check if port 5173 is open: `ss -tlnp | grep 5173` |
| DNS not resolving | Use IP directly: `http://100.x.x.x:5173` |

## Security Notes

- **No open ports:** Tailscale doesn't require opening firewall ports on VPS
- **Encrypted:** All traffic is WireGuard encrypted
- **Authenticated:** Only devices in your Tailscale network can connect
- **No passwords:** Use SSH keys for authentication
- **Audit logs:** Tailscale admin console shows connection logs

## Commands Reference

```bash
# Tailscale status
tailscale status

# Get IP
tailscale ip -4

# SSH via Tailscale
tailscale ssh user@hostname

# Check connection path
tailscale ping hostname

# Exit node (if you want VPS to route internet traffic)
tailscale up --advertise-exit-node

# Disable
tailscale down
```
