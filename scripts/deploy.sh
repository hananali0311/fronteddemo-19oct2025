#!/bin/bash
# =====================================
# Main Deployment Script (AfterInstall)
# =====================================

LOG_FILE="/var/log/deploy.log"
SOURCE_DIR="/opt/new_deploy"
DEST_DIR="/var/www/html"

echo "🚀 Starting deployment..." | tee -a $LOG_FILE

# Step 1: Install Apache & PHP (before copying files)
export DEBIAN_FRONTEND=noninteractive
apt-get update -y >> $LOG_FILE 2>&1
apt-get install -y apache2 php php-mysqli php-cli php-zip unzip curl ruby >> $LOG_FILE 2>&1
systemctl enable apache2 >> $LOG_FILE 2>&1

# Step 2: Copy new files to web root
echo "📁 Copying files from $SOURCE_DIR to $DEST_DIR..." | tee -a $LOG_FILE
cp -r $SOURCE_DIR/* $DEST_DIR/ || { echo "❌ File copy failed!" | tee -a $LOG_FILE; exit 1; }
echo "✅ Files copied successfully to $DEST_DIR." | tee -a $LOG_FILE

# Step 3: Fix permissions
chown -R www-data:www-data $DEST_DIR
chmod -R 755 $DEST_DIR

# Step 4: Install Composer (if not installed)
if ! command -v composer &> /dev/null; then
  echo "📦 Installing Composer..." | tee -a $LOG_FILE
  EXPECTED_SIGNATURE="$(curl -s https://composer.github.io/installer.sig)"
  php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
  ACTUAL_SIGNATURE="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"
  if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]; then
      echo "❌ Invalid Composer installer signature!" | tee -a $LOG_FILE
      rm composer-setup.php
      exit 1
  fi
  php composer-setup.php --quiet
  mv composer.phar /usr/local/bin/composer
  rm composer-setup.php
  echo "✅ Composer installed successfully." | tee -a $LOG_FILE
fi

# Step 5: Install AWS SDK via Composer (only if not already present)
cd $DEST_DIR
if [ ! -f "composer.json" ]; then
  echo "🧾 Creating composer.json for AWS SDK..." | tee -a $LOG_FILE
  echo '{"require": {"aws/aws-sdk-php": "^3.0"}}' > composer.json
fi

echo "📦 Installing AWS SDK for PHP..." | tee -a $LOG_FILE
composer install --no-dev --optimize-autoloader >> $LOG_FILE 2>&1
echo "✅ AWS SDK installed successfully." | tee -a $LOG_FILE

# Step 6: Restart Apache AFTER dependencies installed
systemctl restart apache2 >> $LOG_FILE 2>&1
echo "✅ Apache restarted and dependencies ready." | tee -a $LOG_FILE

# Step 7: Verify index.php and vendor folder exist
if [ -f "$DEST_DIR/index.php" ] && [ -f "$DEST_DIR/vendor/autoload.php" ]; then
  echo "✅ index.php and vendor/autoload.php verified." | tee -a $LOG_FILE
else
  echo "❌ vendor/autoload.php missing!" | tee -a $LOG_FILE
  exit 1
fi

echo "🎉 Deployment complete! Application is live." | tee -a $LOG_FILE
exit 0
