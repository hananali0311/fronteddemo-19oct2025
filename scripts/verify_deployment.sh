#!/bin/bash
LOG_FILE="/var/log/deploy.log"

echo "🔍 Verifying deployment for ALB..." | tee -a $LOG_FILE

# Check if Apache is running
if systemctl is-active --quiet apache2; then
    echo "✅ Apache is running" | tee -a $LOG_FILE
else
    echo "❌ Apache is not running" | tee -a $LOG_FILE
    exit 1
fi

# Check if PHP file is accessible locally
if curl -f http://localhost/index.php > /dev/null 2>&1; then
    echo "✅ PHP application is serving correctly" | tee -a $LOG_FILE
else
    echo "❌ PHP application not accessible" | tee -a $LOG_FILE
    exit 1
fi

echo "✅ ALB deployment verified" | tee -a $LOG_FILE
exit 0