---
name: secure-droplet-bootstrap
description: Guide lockout-safe baseline hardening for a new DigitalOcean Ubuntu droplet using reviewable scripts, SSH recovery checks, UFW, unattended updates, and cloud firewall validation.
---

# secure-droplet-bootstrap

Use this skill when a user wants to initialize or harden a new DigitalOcean Ubuntu droplet.

## Workflow

1. Confirm the target host, Ubuntu version, desired admin username, and intended SSH port.
2. Confirm the user has DigitalOcean console access and at least one active SSH session.
3. Inspect the scripts before suggesting apply mode.
4. Run `sudo ./scripts/harden-ubuntu.sh` first to produce a dry-run plan.
5. Only run apply mode after the user confirms the recovery path:

```bash
sudo APPLY=1 ADMIN_USER=deploy SSH_PORT=22 ./scripts/harden-ubuntu.sh
```

6. Run the audit script after changes:

```bash
sudo ./scripts/audit-droplet.sh
```

## Safety Rules

- Never disable password login or root login before a key-based admin user is verified.
- Never enable UFW before the intended SSH port is allowed.
- Do not claim the server is fully secure. Report the baseline controls that passed and the remaining work.
- Keep DigitalOcean Cloud Firewall setup separate from host firewall setup.
- Do not print secrets, private keys, or tokens.

## Expected Output

Return:

- controls applied
- controls skipped
- audit result
- recovery notes
- next hardening steps specific to the application
