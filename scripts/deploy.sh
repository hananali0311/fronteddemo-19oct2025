#!/bin/bash
# =====================================
# Main Deployment Script (AfterInstall)
# =====================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/opt/new_deploy"
DEST_DIR="/var/www/html"

echo "🚀 Starting deployment..." | tee -a $LOG_FILE

# Copy new files to web root
cp -r $SOURCE_DIR/* $DEST_DIR/ || { echo "❌ File copy failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Files copied successfully to $DEST_DIR." | tee -a $LOG_FILE

# Install dependencies
export DEBIAN_FRONTEND=noninteractive
apt-get update -y >> $LOG_FILE 2>&1
apt-get install -y apache2 php php-mysqli ruby >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1

# Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ Apache restarted and permissions fixed." | tee -a $LOG_FILE

echo "🎉 Deployment complete! Application is live." | tee -a $LOG_FILE
exit 0
