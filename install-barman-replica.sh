#!/bin/bash
# -*- encoding: utf-8 -*-

# this script installs barman on database backup server 10.1.1.11

#sudo apt-get update
#sudo apt-get upgrade -y

sudo apt-get install pip
sudo pip install barman

sudo passwd barman

sudo su barman
cd ~
ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub postgres@10.1.1.15

touch ~/.pgpass
chmod 600 ~/.pgpass
echo "10.1.1.15:*:*:postgres:kt471012" >> ~/.pgpass

psql -c 'SELECT version()' -U postgres -h 10.1.1.15

sudo rm $BAR_CONFIG
sudo touch $BAR_CONFIG
sudo chmod 644 $BAR_CONFIG

echo '#!/bin/sh' >> ~/$BAR_CONFIG
echo '




echo '; Barman, Backup and Recovery Manager for PostgreSQL
echo '; http://www.pgbarman.org/ - http://www.2ndQuadrant.com/
echo ';
echo '; Main configuration file
echo '
echo '[barman]
echo '; Main directory
echo 'barman_home = /var/lib/barman

echo '; Locks directory - default: %(barman_home)s
echo ';barman_lock_directory = /var/run/barman
echo '
echo '; System user
echo 'barman_user = barman

echo '; Log location
echo 'log_file = /var/log/barman/barman.log

echo '; Default compression level: possible values are None (default), bzip2, gzip or$
echo 'compression = gzip

echo '; Incremental backup support: possible values are None (default), link or copy
echo 'reuse_backup = link

echo '; Pre/post backup hook scripts
echo ';pre_backup_script = env | grep ^BARMAN
echo ';pre_backup_retry_script = env | grep ^BARMAN
echo ';post_backup_retry_script = env | grep ^BARMAN
echo ';post_backup_script = env | grep ^BARMAN

echo '; Pre/post archive hook scripts
echo ';pre_archive_script = env | grep ^BARMAN
echo ';pre_archive_retry_script = env | grep ^BARMAN
echo ';post_archive_retry_script = env | grep ^BARMAN
echo 'post_archive_script = env | grep ^BARMAN

echo '; Directory of configuration files. Place your sections in separate files with $
echo '; For example place the 'main' server section in /etc/barman.d/main.conf
echo ';configuration_files_directory = /etc/barman.d
echo '
echo '; Minimum number of required backups (redundancy) - default 0
echo 'minimum_redundancy = 1
echo '
echo '; Global retention policy (REDUNDANCY or RECOVERY WINDOW) - default empty
echo ';retention_policy =

echo '; Global bandwidth limit in KBPS - default 0 (meaning no limit)
echo 'bandwidth_limit = 4000

echo '; Immediate checkpoint for backup command - default false
;immediate_checkpoint = false

; Enable network compression for data transfers - default false
network_compression = true

; Identify the standard behavior for backup operations: possible values are
; exclusive_backup (default), concurrent_backup
;backup_options = exclusive_backup

; Number of retries of data copy during base backup after an error - default 0
;basebackup_retry_times = 0

; Number of seconds of wait after a failed copy, before retrying - default 30
;basebackup_retry_sleep = 30

; Time frame that must contain the latest backup date.
; If the latest backup is older than the time frame, barman check
; command will report an error to the user.
; If empty, the latest backup is always considered valid.
; Syntax for this option is: "i (DAYS | WEEKS | MONTHS)" where i is an
; integer > 0 which identifies the number of days | weeks | months of
; validity of the latest backup for this check. Also known as 'smelly backup'.
;last_backup_maximum_age =

;; ; 'main' PostgreSQL Server configuration
[main]
;; ; Human readable description
description =  "Main PostgreSQL Database"
;;
;; ; SSH options
ssh_command = ssh postgres@10.1.1.15
;;
;; ; PostgreSQL connection string
conninfo = host=10.1.1.15 user=postgres
;;
;; ; PostgreSQL streaming connection string
;;streaming_conninfo = host=pg user=postgres
;;
;; ; Minimum number of required backups (redundancy)
minimum_redundancy = 1
;;
;; ; Examples of retention policies
;;
;; ; Retention policy (disabled)
;; ; retention_policy =
;; ; Retention policy (based on redundancy)
;; ; retention_policy = REDUNDANCY 2
;; ; Retention policy (based on recovery window)
retention_policy = RECOVERY WINDOW OF 4 WEEKS
retention_policy_mode = auto
wal_retention_policy = main

