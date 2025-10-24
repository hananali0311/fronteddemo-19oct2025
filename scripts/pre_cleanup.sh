#!/bin/bash
# =====================================
# Pre-Cleanup Script (BeforeInstall)
# =====================================

LOG_FILE="/var/log/pre_cleanup.log"

echo "🧹 Starting pre-cleanup..." | tee -a $LOG_FILE

# Stop Apache gracefully
systemctl stop apache2 >/dev/null 2>&1 || true

# Remove old deployment directories safely
rm -rf /opt/new_deploy || true
rm -rf /var/www/html || true

# Recreate clean directories
mkdir -p /opt/new_deploy
mkdir -p /var/www/html

echo "✅ Cleanup complete. Fresh environment ready for new deployment." | tee -a $LOG_FILE
exit 0
