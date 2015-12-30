#!/bin/bash
# -*- encoding: utf-8 -*-

# this script installs barman on source database computer 10.1.1.15 and backup is 10.1.1.11

echo -e "---- Decide system passwords ----"
read -e  -p "Decide a strong  password for postgreSQL postgres database user for remote connection: " POSTGRES_DBPASS
echo -e "\n"
read -e -p "Decide a password for postgres system ssh user on this machine : " PG_USERPASS

read -e  -p "Enter backup server name: " BACKUP_IP
echo -e "\n"

sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password '$POSTGRES_DBPASS';"

sudo su root -c "echo 'host    all             all             $BACKUPIP/32             md5' >> /etc/postgresql/9.3/main/pg_hba.conf"

sudo sed -i s/"#wal_level = minimal'"/"wal_level = archive"/g /etc/postgresql/9.3/main/postgresql.conf
sudo sed -i s/"#archive_mode = off'"/"archive_mode = on"/g /etc/postgresql/9.3/main/postgresql.conf
sudo sed -i s/"#archive_command = ''"/"archive_command = 'rsync -a %p barman@$BACKUP_IP:/var/lib/barman/main/incoming/%f'"/g /etc/postgresql/9.3/main/postgresql.conf


sudo su postgres -c "ssh-keygen"
sudo su postgres -c "ssh-copy-id -i ~/.ssh/id_rsa.pub barman@$BACKUP_IP"

echo -e "\nPlease move to the barman backup machine and run install script give credentials below"
echo -e "\npostgres db user pass :$POSTGRES_DBPASS"
echo -e "\npostgres ssh system user pass :$PG_USERPASS"
echo -e "\nWhen prompted on backup machine continue this script to finalize"
while true; do
    read -p "Is backup machine ready for ssh connection, proceed (y/n)?" yn
    case $yn in
        [Yy]* ) sudo su postgres -c "ssh-keygen"
        sudo su postgres -c "ssh-copy-id -i ~/.ssh/id_rsa.pub barman@$BACKUP_IP"
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


while true; do
    read -p "Would you like to restart your postgreSQL server now (y/n)?" yn
    case $yn in
        [Yy]* ) sudo service postgresql restart
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


