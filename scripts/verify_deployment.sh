#!/bin/bash
# ==========================================
# ALB Deployment Verification Script
# ==========================================

LOG_FILE="/var/log/deploy_verify.log"

echo "🔍 Verifying deployment for ALB..." | tee -a $LOG_FILE

# Check if Apache is running
if systemctl is-active --quiet apache2; then
    echo "✅ Apache is running" | tee -a $LOG_FILE
else
    echo "❌ Apache is not running" | tee -a $LOG_FILE
    systemctl status apache2 >> $LOG_FILE 2>&1
    exit 1
fi

# Check if PHP file is accessible locally
if curl -f http://localhost/index.php > /dev/null 2>&1; then
    echo "✅ PHP application is serving correctly" | tee -a $LOG_FILE
else
    echo "❌ PHP application not accessible locally" | tee -a $LOG_FILE
    exit 1
fi

# Check if required PHP extensions are loaded
php -m | grep -i curl >> $LOG_FILE 2>&1
php -m | grep -i mysqli >> $LOG_FILE 2>&1

echo "✅ ALB deployment verified successfully" | tee -a $LOG_FILE
exit 0