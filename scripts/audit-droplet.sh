#!/usr/bin/env bash
set -euo pipefail

check() {
  local label="$1"
  shift
  if "$@" >/dev/null 2>&1; then
    printf '[ok] %s\n' "$label"
  else
    printf '[warn] %s\n' "$label"
  fi
}

echo "Mirogate droplet baseline audit"
echo

check "Ubuntu release detected" test -f /etc/os-release
if [[ -f /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  echo "OS: ${PRETTY_NAME:-unknown}"
fi

check "UFW installed" command -v ufw
if command -v ufw >/dev/null 2>&1; then
  ufw status verbose || true
fi

check "fail2ban installed" command -v fail2ban-client
check "unattended-upgrades installed" dpkg -s unattended-upgrades
check "sshd config validates" sshd -t
check "root SSH login disabled in effective config" sh -c "sshd -T | grep -qi '^permitrootlogin no$'"
check "password SSH auth disabled in effective config" sh -c "sshd -T | grep -qi '^passwordauthentication no$'"

echo
echo "Audit complete. Review warnings against your application and recovery policy."
