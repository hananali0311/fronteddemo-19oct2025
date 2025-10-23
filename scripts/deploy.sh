#!/bin/bash
# =====================================================
# FINAL CLEAN & OPTIMIZED DEPLOY SCRIPT
# =====================================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/opt/new_deploy"
DEST_DIR="/var/www/html"

echo "🚀 Starting clean deployment..." | tee -a $LOG_FILE

# 1️⃣ Stop Apache if it's running
if systemctl is-active --quiet apache2; then
    systemctl stop apache2
    echo "✅ Apache stopped before deployment." | tee -a $LOG_FILE
fi

# 2️⃣ Cleanup old files
echo "🧹 Cleaning up old deployment and temp data..." | tee -a $LOG_FILE
rm -rf /opt/codedeploy-agent/deployment-root/* >> $LOG_FILE 2>&1
rm -rf /tmp/* >> $LOG_FILE 2>&1
rm -rf ${DEST_DIR:?}/* >> $LOG_FILE 2>&1
echo "✅ Cleanup complete." | tee -a $LOG_FILE

# 3️⃣ Recreate destination folder
mkdir -p $DEST_DIR
echo "📁 Recreated $DEST_DIR directory." | tee -a $LOG_FILE

# 4️⃣ Copy new files from CodeDeploy bundle
if [ -d "$SOURCE_DIR" ]; then
    cp -r $SOURCE_DIR/* $DEST_DIR/ >> $LOG_FILE 2>&1
    echo "✅ New files copied from $SOURCE_DIR to $DEST_DIR." | tee -a $LOG_FILE
else
    echo "❌ Source directory $SOURCE_DIR not found!" | tee -a $LOG_FILE
    exit 1
fi

# 5️⃣ Install dependencies (optimized)
echo "📦 Checking dependencies..." | tee -a $LOG_FILE
export DEBIAN_FRONTEND=noninteractive
if ! command -v apache2 >/dev/null 2>&1; then
    echo "🧰 Installing Apache, PHP, and Ruby..." | tee -a $LOG_FILE
    apt-get update -y >> $LOG_FILE 2>&1
    apt-get install -y apache2 php php-mysqli ruby >> $LOG_FILE 2>&1
    echo "✅ Dependencies installed fresh." | tee -a $LOG_FILE
else
    echo "⏩ Dependencies already installed — skipping apt install." | tee -a $LOG_FILE
fi

# 6️⃣ Enable and restart Apache
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Apache started successfully." | tee -a $LOG_FILE

# 7️⃣ Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ Permissions fixed." | tee -a $LOG_FILE

# 8️⃣ Final confirmation
echo "🎉 Deployment complete! Application is live at $(hostname -I | awk '{print $1}')" | tee -a $LOG_FILE
touch /tmp/deploy_success.txt

exit 0
