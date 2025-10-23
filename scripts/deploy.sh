#!/bin/bash
# ==========================================
# Clean Wipe Deployment Script (Final Simple Version)
# ==========================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/tmp/deployment_temp"
DEST_DIR="/var/www/html"

echo "🚀 Starting CLEAN deployment..." | tee -a $LOG_FILE

# Step 1: Stop Apache (optional for clean deploy)
echo "🛑 Stopping Apache service..." | tee -a $LOG_FILE
systemctl stop apache2 >> $LOG_FILE 2>&1 || true

# Step 2: Delete EVERYTHING from web root and temp folders
echo "🔥 Removing old application files..." | tee -a $LOG_FILE
rm -rf ${DEST_DIR:?}/* ${SOURCE_DIR:?}/* >> $LOG_FILE 2>&1
echo "✅ All old files deleted." | tee -a $LOG_FILE

# Step 3: Move new files into place
echo "📦 Deploying fresh code to $DEST_DIR..." | tee -a $LOG_FILE
mkdir -p $DEST_DIR
cp -r /tmp/deployment_temp/* $DEST_DIR/ || { echo "❌ Copy failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Files deployed successfully." | tee -a $LOG_FILE

# Step 4: Install dependencies
echo "⚙️ Installing required packages..." | tee -a $LOG_FILE
export DEBIAN_FRONTEND=noninteractive
apt update -y >> $LOG_FILE 2>&1
apt install -y apache2 php php-mysqli ruby >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Apache and PHP installed and running." | tee -a $LOG_FILE

# Step 5: Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ Permissions fixed." | tee -a $LOG_FILE

# Step 6: Restart CodeDeploy agent (optional)
echo "🔄 Restarting CodeDeploy agent for a clean state..." | tee -a $LOG_FILE
systemctl restart codedeploy-agent >> $LOG_FILE 2>&1 || echo "⚠️ Could not restart CodeDeploy agent." | tee -a $LOG_FILE

# Step 7: Finish
echo "🎯 Deployment finished successfully — everything is clean and new." | tee -a $LOG_FILE
exit 0
