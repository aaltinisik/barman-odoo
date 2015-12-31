#!/bin/bash
# -*- encoding: utf-8 -*-

# this script installs barman on source database computer 10.1.1.15 and backup is 10.1.1.11
PGCONF=/etc/postgresql/9.3/main/postgresql.conf
PGHBA=/etc/postgresql/9.3/main/pg_hba.conf

sudo apt-get install sshpass

echo -e "---- Decide system passwords ----"
read -e -p "Decide a strong  password for postgreSQL postgres database user for remote connection: " POSTGRES_DBPASS
read -e -p "Decide a password for postgres system ssh user on this machine : " PG_USERPASS
read -e -p "Enter backup server name: " BACKUP_IP

sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password '$POSTGRES_DBPASS';"
sudo su root -c "echo 'host    all             all             $BACKUP_IP/32             md5' >> $PGHBA"

sudo sed -i s/"wal_level ="/"#wal_level ="/g $PGCONF
sudo sed -i s/"archive_mode ="/"#archive_mode ="/g $PGCONF
sudo sed -i s^"archive_command ="^"#archive_command ="^g $PGCONF

sudo su root -c "echo 'wal_level = archive' >> $PGCONF"
sudo su root -c "echo 'archive_mode = on' >> $PGCONF"
ARCHIVE_COMMAND="archive_command = \'rsync -a %p barman@$BACKUP_IP:/var/lib/barman/main/incoming/%f\'"
sudo su root -c "echo $ARCHIVE_COMMAND >> $PGCONF"

echo -e "\nPlease move to the barman backup machine and run install script give credentials below"
echo -e "\npostgres db user pass :$POSTGRES_DBPASS"
echo -e "\npostgres ssh system user pass :$PG_USERPASS"
echo -e "\nWhen prompted on backup machine continue this script to finalize on postgreSQL side"
while true; do
    read -p "Is backup machine ready for ssh connection, proceed (y/n)?" yn
    case $yn in
        [Yy]* ) sudo su postgres -c "ssh-keygen -t rsa -N ''"
        read -e -p "Enter barman user SSH password at backup server to copy ssh keys $BACKUP_IP: " BARMAN_PASS
        sudo su postgres -c "sshpass -p '$BARMAN_PASS' ssh-copy-id -i /var/lib/postgresql/.ssh/id_rsa.pub barman@$BACKUP_IP"
        break;;
        [Nn]* ) exit
	break;;
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

echo -e "\nOperation on this side is complete."
echo -e "\nPlease make a ssh test if it is working now with command: ssh barman@BACKUP_IP"
while true; do
    read -p "Would you like to make the ssh test now (you will need to exit from ssh shell with exit command) (y/n)?" yn
    case $yn in
        [Yy]* )  sudo su postgres -c "ssh barman@$BACKUP_IP"
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

