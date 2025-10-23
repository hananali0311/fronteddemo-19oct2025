#!/bin/bash
# ==========================================
# Final Deploy Script – Clean & Reliable
# ==========================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/opt/new_deploy"
DEST_DIR="/var/www/html"

echo "🚀 Starting deployment..." | tee -a $LOG_FILE

# Step 1: Safety cleanup in case any files exist
rm -rf ${DEST_DIR:?}/* >> $LOG_FILE 2>&1
echo "✅ /var/www/html cleaned." | tee -a $LOG_FILE

# Step 2: Copy new files from CodeDeploy bundle
cp -r $SOURCE_DIR/* $DEST_DIR/ >> $LOG_FILE 2>&1
echo "✅ New files copied to /var/www/html." | tee -a $LOG_FILE

# Step 3: Install required dependencies
export DEBIAN_FRONTEND=noninteractive
apt update -y >> $LOG_FILE 2>&1
apt install -y apache2 php php-mysqli ruby >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Apache installed and restarted." | tee -a $LOG_FILE

# Step 4: Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ File permissions fixed." | tee -a $LOG_FILE

# Step 5: Finish deployment
echo "🎉 Deployment successful!" | tee -a $LOG_FILE
touch /tmp/deploy_success.txt

exit 0
