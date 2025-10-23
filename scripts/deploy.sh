#!/bin/bash
# ==========================================
# Final Clean Deployment Script
# ==========================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/opt/new_deploy"
DEST_DIR="/var/www/html"

echo "🚀 Starting deployment..." | tee -a $LOG_FILE

# Step 1: Stop Apache
systemctl stop apache2 >> $LOG_FILE 2>&1 || true

# Step 2: Wipe old web files
echo "🧹 Cleaning $DEST_DIR..." | tee -a $LOG_FILE
rm -rf ${DEST_DIR:?}/* >> $LOG_FILE 2>&1
echo "✅ Old files removed." | tee -a $LOG_FILE

# Step 3: Copy new files
echo "📦 Copying new files from $SOURCE_DIR..." | tee -a $LOG_FILE
cp -rT $SOURCE_DIR $DEST_DIR || { echo "❌ Copy failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Files copied successfully." | tee -a $LOG_FILE

# Step 4: Install dependencies
export DEBIAN_FRONTEND=noninteractive
apt update -y >> $LOG_FILE 2>&1
apt install -y apache2 php php-mysqli ruby >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Apache restarted and PHP installed." | tee -a $LOG_FILE

# Step 5: Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ Permissions fixed." | tee -a $LOG_FILE

# Step 6: Complete
echo "🎯 Deployment successful and application is live!" | tee -a $LOG_FILE
exit 0
