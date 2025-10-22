#!/bin/bash
# ==========================================
# Unified Deployment Script (Final + Self-Healing)
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
apt install -y apache2 php php-mysqli ruby >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Dependencies installed and Apache restarted." | tee -a $LOG_FILE

# Step 4: Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR
echo "✅ Permissions fixed." | tee -a $LOG_FILE

# Step 5: Confirm completion
echo "🎉 Deployment complete! Application is running." | tee -a $LOG_FILE
touch /tmp/deploy_success.txt

# Step 6: Restart CodeDeploy agent to ensure it stays healthy
echo "🔄 Restarting CodeDeploy agent for fresh sync..." | tee -a $LOG_FILE
if systemctl list-units --type=service | grep -q codedeploy-agent; then
    systemctl restart codedeploy-agent >> $LOG_FILE 2>&1
    echo "✅ CodeDeploy agent restarted successfully." | tee -a $LOG_FILE
else
    echo "⚠️ CodeDeploy agent not found — skipping restart." | tee -a $LOG_FILE
fi

# Step 7: Exit cleanly
echo "✅ Deployment script finished successfully." | tee -a $LOG_FILE
exit 0
