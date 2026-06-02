# DigitalOcean Cloud Firewall Checklist

Use this checklist before enabling host-level firewall changes.

## Required

- Attach a DigitalOcean Cloud Firewall to the droplet.
- Allow SSH only from trusted IP ranges where possible.
- Confirm the SSH port matches the server-side `SSH_PORT` value.
- Allow HTTP `80/tcp` and HTTPS `443/tcp` only when the droplet serves web traffic.
- Deny all other inbound traffic by default.
- Keep outbound traffic open unless the application has a stricter egress policy.

## Verification

```bash
ssh -p "$SSH_PORT" "$ADMIN_USER@$SERVER_IP"
curl -I "http://$SERVER_IP"
curl -I "https://$SERVER_IP"
```

If HTTP or HTTPS should not be public, those checks should fail from the public internet.

## Recovery

- Keep DigitalOcean console access available.
- Keep one SSH session open while changing firewall rules.
- If SSH is blocked, use the console to disable or adjust UFW:

```bash
sudo ufw status verbose
sudo ufw allow 22/tcp
sudo ufw reload
```
