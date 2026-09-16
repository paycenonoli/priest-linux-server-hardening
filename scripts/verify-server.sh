#!/bin/bash

echo "=== Linux Server Health Check ==="
echo

echo "Hostname:"
hostname

echo
echo "Uptime:"
uptime

echo
echo "Memory:"
free -h

echo
echo "Disk:"
df -h /

echo
echo "=== Service Status ==="

for service in ssh nginx fail2ban; do
    if systemctl is-active --quiet "$service"; then
        echo "[OK] $service is active"
    else
        echo "[FAIL] $service is not active"
    fi
done

