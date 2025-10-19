#!/bin/bash
set -e
# Remove old files
sudo rm -rf /var/www/html/*
chmod +x /opt/codedeploy-agent/deployment-root/*/*/scripts/*.sh || true
