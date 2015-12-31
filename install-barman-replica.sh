#!/bin/bash
# -*- encoding: utf-8 -*-

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
sudo apt-get install pip
sudo pip install barman
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
sudo chmod 777 $BAR_CONFIG

echo '#!/bin/sh' >> $BAR_CONFIG

echo '; Barman, Backup and Recovery Manager for PostgreSQL' >> $BAR_CONFIG
echo '; http://www.pgbarman.org/ - http://www.2ndQuadrant.com/' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Main configuration file' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '[barman]' >> $BAR_CONFIG
echo '; Main directory' >> $BAR_CONFIG
echo 'barman_home = /var/lib/barman' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Locks directory - default: %(barman_home)s' >> $BAR_CONFIG
echo ';barman_lock_directory = /var/run/barman' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; System user' >> $BAR_CONFIG
echo 'barman_user = barman' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Log location' >> $BAR_CONFIG
echo 'log_file = /var/log/barman/barman.log' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Default compression level: possible values are None (default), bzip2, gzip or custom' >> $BAR_CONFIG
echo 'compression = gzip' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Incremental backup support: possible values are None (default), link or copy' >> $BAR_CONFIG
echo 'reuse_backup = link' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Pre/post backup hook scripts' >> $BAR_CONFIG
echo ';pre_backup_script = env | grep ^BARMAN' >> $BAR_CONFIG
echo ';pre_backup_retry_script = env | grep ^BARMAN' >> $BAR_CONFIG
echo ';post_backup_retry_script = env | grep ^BARMAN' >> $BAR_CONFIG
echo ';post_backup_script = env | grep ^BARMAN' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Pre/post archive hook scripts' >> $BAR_CONFIG
echo ';pre_archive_script = env | grep ^BARMAN' >> $BAR_CONFIG
echo ';pre_archive_retry_script = env | grep ^BARMAN' >> $BAR_CONFIG
echo ';post_archive_retry_script = env | grep ^BARMAN' >> $BAR_CONFIG
echo 'post_archive_script = env | grep ^BARMAN' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Directory of configuration files. Place your sections in separate files with .conf extension' >> $BAR_CONFIG
echo '; For example place the main server section in /etc/barman.d/main.conf' >> $BAR_CONFIG
echo ';configuration_files_directory = /etc/barman.d' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Minimum number of required backups (redundancy) - default 0' >> $BAR_CONFIG
echo 'minimum_redundancy = 1' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Global retention policy (REDUNDANCY or RECOVERY WINDOW) - default empty' >> $BAR_CONFIG
echo ';retention_policy =' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Global bandwidth limit in KBPS - default 0 (meaning no limit)' >> $BAR_CONFIG
echo 'bandwidth_limit = 1000' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Immediate checkpoint for backup command - default false' >> $BAR_CONFIG
echo ';immediate_checkpoint = false' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Enable network compression for data transfers - default false' >> $BAR_CONFIG
echo 'network_compression = true' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Identify the standard behavior for backup operations: possible values are' >> $BAR_CONFIG
echo '; exclusive_backup (default), concurrent_backup' >> $BAR_CONFIG
echo ';backup_options = exclusive_backup' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Number of retries of data copy during base backup after an error - default 0' >> $BAR_CONFIG
echo ';basebackup_retry_times = 0' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Number of seconds of wait after a failed copy, before retrying - default 30' >> $BAR_CONFIG
echo ';basebackup_retry_sleep = 30' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo '; Time frame that must contain the latest backup date.' >> $BAR_CONFIG
echo '; If the latest backup is older than the time frame, barman check' >> $BAR_CONFIG
echo '; command will report an error to the user.' >> $BAR_CONFIG
echo '; If empty, the latest backup is always considered valid.' >> $BAR_CONFIG
echo '; Syntax for this option is: "i (DAYS | WEEKS | MONTHS)" where i is an' >> $BAR_CONFIG
echo '; integer > 0 which identifies the number of days | weeks | months of' >> $BAR_CONFIG
echo '; validity of the latest backup for this check. Also known as smelly backup.' >> $BAR_CONFIG
echo ';last_backup_maximum_age =' >> $BAR_CONFIG
echo ';' >> $BAR_CONFIG
echo ';; ; main PostgreSQL Server configuration' >> $BAR_CONFIG
echo '[main]' >> $BAR_CONFIG
echo ';; ; Human readable description' >> $BAR_CONFIG
echo 'description =  "Main PostgreSQL Database"' >> $BAR_CONFIG
echo ';;' >> $BAR_CONFIG
echo ';; ; SSH options' >> $BAR_CONFIG
echo 'ssh_command = ssh postgres@$PG_IP' >> $BAR_CONFIG
echo ';;' >> $BAR_CONFIG
echo ';; ; PostgreSQL connection string' >> $BAR_CONFIG
echo 'conninfo = host=$PG_IP user=postgres' >> $BAR_CONFIG
echo ';;' >> $BAR_CONFIG
echo ';; ; PostgreSQL streaming connection string' >> $BAR_CONFIG
echo ';;streaming_conninfo = host=pg user=postgres' >> $BAR_CONFIG
echo ';;' >> $BAR_CONFIG
echo ';; ; Minimum number of required backups (redundancy)' >> $BAR_CONFIG
echo 'minimum_redundancy = 1' >> $BAR_CONFIG
echo ';;' >> $BAR_CONFIG
echo ';; ; Examples of retention policies' >> $BAR_CONFIG
echo ';;' >> $BAR_CONFIG
echo ';; ; Retention policy (disabled)' >> $BAR_CONFIG
echo ';; ; retention_policy =' >> $BAR_CONFIG
echo ';; ; Retention policy (based on redundancy)' >> $BAR_CONFIG
echo ';; ; retention_policy = REDUNDANCY 2' >> $BAR_CONFIG
echo ';; ; Retention policy (based on recovery window)' >> $BAR_CONFIG
echo 'retention_policy = RECOVERY WINDOW OF 4 WEEKS' >> $BAR_CONFIG
echo 'retention_policy_mode = auto' >> $BAR_CONFIG
echo 'wal_retention_policy = main' >> $BAR_CONFIG

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
    read -p "Would you like to restart this server server now (y/n)?" yn
    case $yn in
        [Yy]* ) sudo reboot
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


