#!/bin/bash
# ==========================================
# Unified Deployment Script (Final)
# ==========================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/tmp/deployment_temp"
DEST_DIR="/var/www/html"

echo "🚀 Starting deployment..." | tee -a $LOG_FILE

# Step 1: Cleanup
echo "🧹 Cleaning old deployment files in $DEST_DIR..." | tee -a $LOG_FILE
rm -rf ${DEST_DIR:?}/* || { echo "❌ Cleanup failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Cleanup complete." | tee -a $LOG_FILE

# Step 2: Move new files from temporary folder
echo "📂 Moving new files from $SOURCE_DIR to $DEST_DIR..." | tee -a $LOG_FILE
cp -r $SOURCE_DIR/* $DEST_DIR/ || { echo "❌ File copy failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Files moved successfully." | tee -a $LOG_FILE

# Step 3: Install dependencies
echo "📦 Installing dependencies..." | tee -a $LOG_FILE
export DEBIAN_FRONTEND=noninteractive
apt update -y >> $LOG_FILE 2>&1
apt install -y apache2 php php-mysqli >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Dependencies installed and Apache restarted." | tee -a $LOG_FILE

# Step 4: Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ Permissions fixed." | tee -a $LOG_FILE

# Step 5: Done
echo "🎉 Deployment complete! Application is running." | tee -a $LOG_FILE

# Optional: Create a flag file to confirm success
touch /tmp/deploy_success.txt

# Exit cleanly so CodeDeploy marks success
exit 0
