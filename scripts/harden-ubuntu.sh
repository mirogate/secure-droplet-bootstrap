#!/usr/bin/env bash
set -euo pipefail

APPLY="${APPLY:-0}"
ADMIN_USER="${ADMIN_USER:-deploy}"
SSH_PORT="${SSH_PORT:-22}"
SSHD_DROPIN="/etc/ssh/sshd_config.d/90-mirogate-baseline.conf"

run() {
  if [[ "$APPLY" == "1" ]]; then
    "$@"
  else
    printf '[dry-run] %q ' "$@"
    printf '\n'
  fi
}

need_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run as root or with sudo." >&2
    exit 1
  fi
}

detect_ubuntu() {
  if [[ ! -f /etc/os-release ]]; then
    echo "Cannot detect operating system." >&2
    exit 1
  fi
  # shellcheck disable=SC1091
  . /etc/os-release
  if [[ "${ID:-}" != "ubuntu" ]]; then
    echo "This script is intended for Ubuntu. Detected: ${PRETTY_NAME:-unknown}" >&2
    exit 1
  fi
}

validate_port() {
  if ! [[ "$SSH_PORT" =~ ^[0-9]+$ ]] || (( SSH_PORT < 1 || SSH_PORT > 65535 )); then
    echo "SSH_PORT must be between 1 and 65535." >&2
    exit 1
  fi
}

service_name() {
  if systemctl list-unit-files | grep -q '^ssh\.service'; then
    echo "ssh"
  else
    echo "sshd"
  fi
}

main() {
  need_root
  detect_ubuntu
  validate_port

  echo "Mirogate secure droplet baseline"
  echo "Mode: $([[ "$APPLY" == "1" ]] && echo apply || echo dry-run)"
  echo "Admin user: $ADMIN_USER"
  echo "SSH port: $SSH_PORT"
  echo

  run apt-get update
  run apt-get install -y ufw fail2ban unattended-upgrades curl ca-certificates

  if id "$ADMIN_USER" >/dev/null 2>&1; then
    echo "Admin user exists: $ADMIN_USER"
  else
    run adduser --disabled-password --gecos "" "$ADMIN_USER"
  fi
  run usermod -aG sudo "$ADMIN_USER"

  run ufw allow "${SSH_PORT}/tcp"
  run ufw default deny incoming
  run ufw default allow outgoing
  if [[ "$APPLY" == "1" ]]; then
    ufw --force enable
  else
    echo "[dry-run] ufw --force enable"
  fi

  run dpkg-reconfigure -f noninteractive unattended-upgrades

  run mkdir -p /etc/ssh/sshd_config.d
  if [[ "$APPLY" == "1" ]]; then
    cat > "$SSHD_DROPIN" <<EOF
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
Port $SSH_PORT
EOF
    sshd -t
    systemctl restart "$(service_name)"
  else
    echo "[dry-run] write $SSHD_DROPIN with root login disabled, password auth disabled, and Port $SSH_PORT"
    echo "[dry-run] sshd -t"
    echo "[dry-run] systemctl restart $(service_name)"
  fi

  echo
  echo "Next: keep this SSH session open, open a second session as $ADMIN_USER, then run scripts/audit-droplet.sh."
}

main "$@"
