#!/bin/bash
LOG_FILE="/var/log/pre_cleanup.log"

echo "🧹 Cleaning /opt/new_deploy before new deployment..." | tee -a $LOG_FILE
rm -rf /opt/new_deploy/* || true
mkdir -p /opt/new_deploy
chown -R ubuntu:ubuntu /opt/new_deploy
echo "✅ /opt/new_deploy cleaned successfully." | tee -a $LOG_FILE
