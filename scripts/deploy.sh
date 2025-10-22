#!/bin/bash
# ==========================================
# Unified Deployment Script
# Works with AWS CodeDeploy & Manual Execution
# ==========================================

LOG_FILE="/var/log/deploy.log"

echo "🚀 Starting deployment script..." | tee -a $LOG_FILE

# Step 1: Cleanup old files
echo "🧹 Cleaning up old deployment files..." | tee -a $LOG_FILE
rm -rf /var/www/html/* || { echo "❌ Cleanup failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Cleanup complete." | tee -a $LOG_FILE

# Step 2: Copy new files (in case running manually)
if [ ! -f /var/www/html/index.php ]; then
  echo "📂 Copying application files..." | tee -a $LOG_FILE
  cp -r /home/ubuntu/app/* /var/www/html/ 2>/dev/null || true
fi

# Step 3: Install dependencies
echo "📦 Installing dependencies..." | tee -a $LOG_FILE
apt update -y >> $LOG_FILE 2>&1
apt install -y apache2 php php-mysqli >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Dependencies installed and Apache restarted." | tee -a $LOG_FILE

# Step 4: Permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Step 5: Final confirmation
echo "🎉 Deployment complete. Application is running!" | tee -a $LOG_FILE
echo "✅ Check Apache: http://<your-ec2-public-ip> or http://localhost" | tee -a $LOG_FILE
