#!/bin/bash

THRESHOLD=90
RECORDINGS_DIR="/var/spool/asterisk/monitor"
LOG_DIR="/var/log/asterisk"

echo "=== Starting Asterisk Maintenance Check ==="

# 1. Check Disk Space Usage
DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
echo "Current root disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -ge "$THRESHOLD" ]; then
    echo "WARNING: Disk usage has reached ${THRESHOLD}%. Cleaning up old recordings..."
    
    # Safe delete: Remove recordings older than 90 days first
    find "$RECORDINGS_DIR" -type f \( -name "*.wav" -o -name "*.mp3" -o -name "*.gsm" \) -mtime +90 -exec rm -f {} \;
    
    # Recheck disk space; if still high, remove the oldest 100 files
    DISK_USAGE=$(df / | grep / | awk '{print $5}' | sed 's/%//g')
    if [ "$DISK_USAGE" -ge "$THRESHOLD" ]; then
        echo "Disk still above ${THRESHOLD}%. Removing oldest 100 recording files..."
        find "$RECORDINGS_DIR" -type f \( -name "*.wav" -o -name "*.mp3" -o -name "*.gsm" \) -printf '%T+ %p\n' | sort | head -n 100 | awk '{print $2}' | xargs rm -f
    fi
else
    echo "Disk usage is within safe limits."
fi

# 2. Check Memory and Swap Usage
echo -e "\n=== Memory & Swap Status ==="
free -h

# Drop page cache, dentries, and inodes safely (frees unused RAM without restarting services)
if [ "$(/usr/bin/free | awk '/Mem:/ {print int($3/$2 * 100)}')" -ge 85 ]; then
    echo "High memory usage detected. Clearing page cache..."
    sync && echo 3 > /proc/sys/vm/drop_caches
fi

# 3. Additional Asterisk Optimization & Cleanup
echo -e "\n=== Running Asterisk Housekeeping ==="

# Rotate logs to prevent single large log files from bloating disk I/O
sudo asterisk -rx "logger rotate" &>/dev/null
echo "Asterisk logs rotated."

# Prune old rotated log files older than 14 days
find "$LOG_DIR" -name "full.*" -mtime +14 -exec rm -f {} \;
echo "Old log archives pruned."

# Clean up stale core dumps if any crashed processes left them behind
find /var/lib/asterisk -name "core.*" -type f -mtime +7 -exec rm -f {} \;
echo "Stale core dumps cleaned."

echo "=== Maintenance Complete ==="