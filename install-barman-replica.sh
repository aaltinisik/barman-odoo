#!/bin/bash
# -*- encoding: utf-8 -*-
# script updated for ubuntu 16.04
# use pass with alphanumeric chars
# this script installs barman on database backup server
BAR_CONFIG="/etc/barman.conf"

echo -e "---- Decide system passwords ----"
read -e -p "Enter Postgresql server address to backup: " PG_IP
read -e -p "Enter password of postgres database user at $PG_IP: " POSTGRES_DBPASS
read -e -p "Decide a password for barman system user on this machine : " BARMAN_USERPASS


echo -e "\n"
echo -e "\nInstalling Barman..."
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install barman
sudo apt-get install sshpass

sudo su root -c "echo barman:$BARMAN_USERPASS | chpasswd"


echo -e "\nGenerating ssh keys and sending to $PG_IP computer..."
sudo su barman -c "ssh-keygen -f /var/lib/barman/.ssh/id_rsa -t rsa -N ''"

echo -e "\nTo add generated ssh fingerprint to backup server,"
read -e -p "Please enter SSH password of postgres system user at $PG_IP : " PG_USERPASS

sudo su barman -c "sshpass -p '$PG_USERPASS' ssh-copy-id -i /var/lib/barman/.ssh/id_rsa.pub postgres@$PG_IP"

echo -e "\nPlease switch to PostgreSQL machine and proceed with copying ssh keys to this machine."
echo -e "\nYou can connect to this machine with SSH user:barman password:$BARMAN_USERPASS"
while true; do
    read -p "Do you want to continue (y/n)?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit 
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done

sudo su barman -c "touch /var/lib/barman/.pgpass"
sudo su barman -c "echo '$PG_IP:*:*:postgres:$POSTGRES_DBPASS' >> /var/lib/barman/.pgpass"
sudo su barman -c "chmod 600 /var/lib/barman/.pgpass"


sudo rm $BAR_CONFIG
sudo touch $BAR_CONFIG

sudo su root -c "echo '#!/bin/sh' >> $BAR_CONFIG"
sudo su root -c "echo '; Barman, Backup and Recovery Manager for PostgreSQL' >> $BAR_CONFIG"
sudo su root -c "echo '; http://www.pgbarman.org/ - http://www.2ndQuadrant.com/' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Main configuration file' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '[barman]' >> $BAR_CONFIG"
sudo su root -c "echo '; Main directory' >> $BAR_CONFIG"
sudo su root -c "echo 'barman_home = /var/lib/barman' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Locks directory - default: %(barman_home)s' >> $BAR_CONFIG"
sudo su root -c "echo ';barman_lock_directory = /var/run/barman' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; System user' >> $BAR_CONFIG"
sudo su root -c "echo 'barman_user = barman' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Log location' >> $BAR_CONFIG"
sudo su root -c "echo 'log_file = /var/log/barman/barman.log' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Default compression level: possible values are None (default), bzip2, gzip or custom' >> $BAR_CONFIG"
sudo su root -c "echo 'compression = gzip' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Incremental backup support: possible values are None (default), link or copy' >> $BAR_CONFIG"
sudo su root -c "echo 'reuse_backup = link' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Pre/post backup hook scripts' >> $BAR_CONFIG"
sudo su root -c "echo ';pre_backup_script = env | grep ^BARMAN' >> $BAR_CONFIG"
sudo su root -c "echo ';pre_backup_retry_script = env | grep ^BARMAN' >> $BAR_CONFIG"
sudo su root -c "echo ';post_backup_retry_script = env | grep ^BARMAN' >> $BAR_CONFIG"
sudo su root -c "echo ';post_backup_script = env | grep ^BARMAN' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Pre/post archive hook scripts' >> $BAR_CONFIG"
sudo su root -c "echo ';pre_archive_script = env | grep ^BARMAN' >> $BAR_CONFIG"
sudo su root -c "echo ';pre_archive_retry_script = env | grep ^BARMAN' >> $BAR_CONFIG"
sudo su root -c "echo ';post_archive_retry_script = env | grep ^BARMAN' >> $BAR_CONFIG"
sudo su root -c "echo ';post_archive_script = env | grep ^BARMAN' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Directory of configuration files. Place your sections in separate files with .conf extension' >> $BAR_CONFIG"
sudo su root -c "echo '; For example place the main server section in /etc/barman.d/main.conf' >> $BAR_CONFIG"
sudo su root -c "echo ';configuration_files_directory = /etc/barman.d' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Minimum number of required backups (redundancy) - default 0' >> $BAR_CONFIG"
sudo su root -c "echo 'minimum_redundancy = 1' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Global retention policy (REDUNDANCY or RECOVERY WINDOW) - default empty' >> $BAR_CONFIG"
sudo su root -c "echo ';retention_policy =' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Global bandwidth limit in KBPS - default 0 (meaning no limit)' >> $BAR_CONFIG"
sudo su root -c "echo 'bandwidth_limit = 1000' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Immediate checkpoint for backup command - default false' >> $BAR_CONFIG"
sudo su root -c "echo ';immediate_checkpoint = false' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Enable network compression for data transfers - default false' >> $BAR_CONFIG"
sudo su root -c "echo 'network_compression = true' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Identify the standard behavior for backup operations: possible values are' >> $BAR_CONFIG"
sudo su root -c "echo '; exclusive_backup (default), concurrent_backup' >> $BAR_CONFIG"
sudo su root -c "echo ';backup_options = exclusive_backup' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Number of retries of data copy during base backup after an error - default 0' >> $BAR_CONFIG"
sudo su root -c "echo ';basebackup_retry_times = 0' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Number of seconds of wait after a failed copy, before retrying - default 30' >> $BAR_CONFIG"
sudo su root -c "echo ';basebackup_retry_sleep = 30' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo '; Time frame that must contain the latest backup date.' >> $BAR_CONFIG"
sudo su root -c "echo '; If the latest backup is older than the time frame, barman check' >> $BAR_CONFIG"
sudo su root -c "echo '; command will report an error to the user.' >> $BAR_CONFIG"
sudo su root -c "echo '; If empty, the latest backup is always considered valid.' >> $BAR_CONFIG"
sudo su root -c "echo '; Syntax for this option is: \"i (DAYS | WEEKS | MONTHS)\" where i is an' >> $BAR_CONFIG"
sudo su root -c "echo '; integer > 0 which identifies the number of days | weeks | months of' >> $BAR_CONFIG"
sudo su root -c "echo '; validity of the latest backup for this check. Also known as smelly backup.' >> $BAR_CONFIG"
sudo su root -c "echo ';last_backup_maximum_age =' >> $BAR_CONFIG"
sudo su root -c "echo ';' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; main PostgreSQL Server configuration' >> $BAR_CONFIG"
sudo su root -c "echo '[main]' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; Human readable description' >> $BAR_CONFIG"
sudo su root -c "echo 'description =  \"Main PostgreSQL Database\"' >> $BAR_CONFIG"
sudo su root -c "echo ';;' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; SSH options' >> $BAR_CONFIG"
sudo su root -c "echo 'ssh_command = ssh postgres@$PG_IP' >> $BAR_CONFIG"
sudo su root -c "echo ';;' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; PostgreSQL connection string' >> $BAR_CONFIG"
sudo su root -c "echo 'conninfo = host=$PG_IP user=postgres' >> $BAR_CONFIG"
sudo su root -c "echo ';;' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; PostgreSQL streaming connection string' >> $BAR_CONFIG"
sudo su root -c "echo ';;streaming_conninfo = host=pg user=postgres' >> $BAR_CONFIG"
sudo su root -c "echo ';;' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; Minimum number of required backups (redundancy)' >> $BAR_CONFIG"
sudo su root -c "echo 'minimum_redundancy = 1' >> $BAR_CONFIG"
sudo su root -c "echo ';;' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; Examples of retention policies' >> $BAR_CONFIG"
sudo su root -c "echo ';;' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; Retention policy (disabled)' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; retention_policy =' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; Retention policy (based on redundancy)' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; retention_policy = REDUNDANCY 2' >> $BAR_CONFIG"
sudo su root -c "echo ';; ; Retention policy (based on recovery window)' >> $BAR_CONFIG"
sudo su root -c "echo 'retention_policy = RECOVERY WINDOW OF 4 WEEKS' >> $BAR_CONFIG"
sudo su root -c "echo 'retention_policy_mode = auto' >> $BAR_CONFIG"
sudo su root -c "echo 'wal_retention_policy = main' >> $BAR_CONFIG"

sudo chmod 644 $BAR_CONFIG

while true; do
    read -p "Would you like to test PostgreSQL DB connection now (y/n)?" yn
    case $yn in
        [Yy]* )  echo -e "---- Try to connect PostgreSQL DB ----"
	echo -e "barman user should be able to connect postgres@$PG_IP with saved password"
	sudo su barman -c "psql -c 'SELECT version()' -U postgres -h $PG_IP"
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo -e "\nOperation on this side is complete."
echo -e "\nPlease make a ssh test if it is working now with command: ssh postgres@PG_IP"
while true; do
    read -p "Would you like to make the ssh test now (you will need to exit from ssh shell with exit command to proceed) (y/n)?" yn
    case $yn in
        [Yy]* )  sudo su barman -c "ssh postgres@$PG_IP"
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
while true; do
    read -p "Would you like to test barman with \"barman check main\" command? (all results needs to be OK) (y/n)?" yn
    case $yn in
        [Yy]* ) sudo su barman -c "barman check main"
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done
echo -e "\nAll Done. Please remenber to add barman to cron for periodical backups."
