# Asterisk Automated Maintenance & Log Pruning

An automated bash script designed to monitor and optimize system resources on Asterisk PBX servers. It automatically manages disk usage, cleans up old call recordings, frees system RAM, and handles Asterisk log rotation and core dump purging.

## Features

* **Disk Usage Monitoring:** Checks root `/` partition space against a configurable threshold (default: `90%`).
* **Dual-Tier Recording Cleanup:** 
  * Safely removes recordings (`.wav`, `.mp3`, `.gsm`) older than 90 days.
  * If disk usage remains critical, automatically deletes the 100 oldest files.
* **Memory Management:** Flushes page cache (`drop_caches`) if system RAM usage exceeds 85%.
* **Asterisk Log & Housekeeping:** 
  * Triggers Asterisk CLI `logger rotate`.
  * Prunes rotated log archives older than 14 days.
  * Removes stale process crash dumps (`core.*`) older than 7 days.

## Prerequisites

* **Operating System:** Linux (CentOS/RHEL/Ubuntu/Debian)
* **PBX Software:** Asterisk installed and running
* **Privileges:** `root` or `sudo` access (required for modifying `/proc/sys/vm/drop_caches` and running Asterisk CLI commands)

## Installation

1. Clone the repository to your server:
   ```bash
   git clone [https://github.com/your-username/asterisk-maintenance.git](https://github.com/your-username/asterisk-maintenance.git)
   cd asterisk-maintenance