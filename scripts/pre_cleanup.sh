#!/bin/bash
# ==========================================
# Pre-cleanup Script for CodeDeploy
# ==========================================

LOG_FILE="/var/log/deploy_cleanup.log"
echo "🧹 Starting pre-cleanup..." | tee -a $LOG_FILE

# Stop Apache safely if running
if systemctl is-active --quiet apache2; then
    systemctl stop apache2
    echo "✅ Apache stopped." | tee -a $LOG_FILE
fi

# Remove previous deployment data and old temp folders
rm -rf /opt/codedeploy-agent/deployment-root/* >> $LOG_FILE 2>&1
rm -rf /opt/new_deploy >> $LOG_FILE 2>&1
rm -rf /tmp/deployment_temp >> $LOG_FILE 2>&1
rm -rf /var/www/html/* >> $LOG_FILE 2>&1

echo "✅ Pre-cleanup done." | tee -a $LOG_FILE
exit 0