# secure-droplet-bootstrap

Lockout-safe baseline hardening for a new DigitalOcean Ubuntu droplet.

This project gives teams a small, reviewable starting point for the first hour of a server:

- a Codex skill for guided hardening work
- a dry-run-by-default hardening script
- a read-only audit script
- a DigitalOcean Cloud Firewall checklist

It is not a compliance framework and does not claim to make a server secure by itself. It creates a disciplined baseline that a team can inspect, adapt, and run with a recovery path in place.

## Quick Start

Review the scripts first:

```bash
bash -n scripts/*.sh
```

Run the hardening script in dry-run mode:

```bash
sudo ./scripts/harden-ubuntu.sh
```

Apply changes explicitly:

```bash
sudo APPLY=1 ADMIN_USER=deploy SSH_PORT=22 ./scripts/harden-ubuntu.sh
```

Audit the current server state:

```bash
sudo ./scripts/audit-droplet.sh
```

## Safety Model

The hardening script is dry-run by default. It will not change the server unless `APPLY=1` is set.

Before applying:

- confirm that DigitalOcean console access works
- keep a second SSH session open
- confirm the SSH port that should remain allowed
- add or verify a DigitalOcean Cloud Firewall rule for that SSH port
- read `docs/digitalocean-firewall-checklist.md`

## What The Apply Mode Does

- Creates or verifies a sudo-capable admin user.
- Installs baseline packages: `ufw`, `fail2ban`, `unattended-upgrades`, `curl`, and `ca-certificates`.
- Allows the configured SSH port in UFW before enabling UFW.
- Enables UFW if inactive.
- Enables unattended security updates.
- Writes an SSH daemon drop-in that disables root login and password authentication.
- Validates SSH configuration before restarting SSH.

## Codex Skill

The skill lives in `skill/SKILL.md`. Install it into your Codex skills directory or copy it into a workspace where Codex can read it before starting server hardening work.

## Test

```bash
npm test
```

The test command runs shell syntax checks. It does not mutate a server.

## License

MIT
