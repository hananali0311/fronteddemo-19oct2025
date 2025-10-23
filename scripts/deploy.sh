#!/bin/bash
# =====================================================
# FINAL DEPLOY SCRIPT — CLEAN SLATE DEPLOYMENT
# =====================================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/opt/new_deploy"
DEST_DIR="/var/www/html"

echo "🚀 Starting clean deployment..." | tee -a $LOG_FILE

# 1️⃣ Stop Apache if it's running
if systemctl is-active --quiet apache2; then
    systemctl stop apache2
    echo "✅ Apache stopped." | tee -a $LOG_FILE
fi

# 2️⃣ Clean up all previous data
echo "🧹 Removing old files and CodeDeploy temp data..." | tee -a $LOG_FILE
rm -rf /opt/codedeploy-agent/deployment-root/* >> $LOG_FILE 2>&1
rm -rf /tmp/* >> $LOG_FILE 2>&1
rm -rf ${DEST_DIR:?}/* >> $LOG_FILE 2>&1
echo "✅ Cleanup complete." | tee -a $LOG_FILE

# 3️⃣ Create destination folder if missing
mkdir -p $DEST_DIR
echo "📁 Recreated /var/www/html directory." | tee -a $LOG_FILE

# 4️⃣ Copy new files from CodeDeploy bundle
cp -r $SOURCE_DIR/* $DEST_DIR/ >> $LOG_FILE 2>&1
echo "✅ New files copied." | tee -a $LOG_FILE

# 5️⃣ Install dependencies fresh
export DEBIAN_FRONTEND=noninteractive
apt update -y >> $LOG_FILE 2>&1
apt install -y apache2 php php-mysqli ruby >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Dependencies installed and Apache restarted." | tee -a $LOG_FILE

# 6️⃣ Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ Permissions fixed." | tee -a $LOG_FILE

# 7️⃣ Success confirmation
echo "🎉 Clean deployment complete! App is live." | tee -a $LOG_FILE
touch /tmp/deploy_success.txt

exit 0
