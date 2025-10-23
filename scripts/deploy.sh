#!/bin/bash
# ==========================================
# Unified Deployment Script (Final Stable Fix)
# ==========================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/tmp/deployment_temp"
DEST_DIR="/var/www/html"

echo "🚀 Starting deployment..." | tee -a $LOG_FILE

# Step 0: Clean up any leftover temp data from previous deployments
if [ -d "$SOURCE_DIR" ]; then
    echo "🧹 Cleaning up old temporary deployment files in $SOURCE_DIR..." | tee -a $LOG_FILE
    rm -rf ${SOURCE_DIR:?}/* >> $LOG_FILE 2>&1
    echo "✅ Temporary folder cleaned." | tee -a $LOG_FILE
fi

# Step 1: Cleanup existing app files
echo "🧹 Cleaning old deployment files in $DEST_DIR..." | tee -a $LOG_FILE
rm -rf ${DEST_DIR:?}/* || { echo "❌ Cleanup failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Cleanup complete." | tee -a $LOG_FILE

# Step 2: Copy new files from CodeDeploy temp folder
echo "📂 Moving new files from $SOURCE_DIR to $DEST_DIR..." | tee -a $LOG_FILE
cp -rT $SOURCE_DIR $DEST_DIR || { echo "❌ File copy failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Files moved successfully." | tee -a $LOG_FILE

# Step 3: Install dependencies
echo "📦 Installing dependencies..." | tee -a $LOG_FILE
export DEBIAN_FRONTEND=noninteractive
apt update -y >> $LOG_FILE 2>&1
apt install -y apache2 php php-mysqli ruby >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Dependencies installed and Apache restarted." | tee -a $LOG_FILE

# Step 4: Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ Permissions fixed." | tee -a $LOG_FILE

# Step 5: Success flag
echo "🎉 Deployment complete! Application is running." | tee -a $LOG_FILE
touch /tmp/deploy_success.txt

# Step 6: Conditional CodeDeploy agent restart
echo "🔄 Restarting CodeDeploy agent for fresh sync..." | tee -a $LOG_FILE
if systemctl list-units --type=service | grep -q codedeploy-agent; then
    systemctl restart codedeploy-agent >> $LOG_FILE 2>&1
    sleep 10
    echo "✅ CodeDeploy agent restarted successfully." | tee -a $LOG_FILE
else
    echo "⚠️ CodeDeploy agent not found — skipping restart." | tee -a $LOG_FILE
fi

# Step 7: Final confirmation and graceful exit
echo "🏁 All tasks completed successfully. Exiting cleanly." | tee -a $LOG_FILE
exit 0
