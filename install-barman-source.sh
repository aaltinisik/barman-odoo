#!/bin/bash
# -*- encoding: utf-8 -*-

# this script installs barman on source database computer 10.1.1.15 and backup is 10.1.1.11

echo -e "---- Decide system passwords ----"
read -e  -p "Enter a strong  password for postgreSQL postgres user for remote connection: " POSTGRES_USERPASS
echo -e "\n"
read -e  -p "Enter backup server name: " BACKUP_IP
echo -e "\n"

#sudo apt-get update
#sudo apt-get upgrade -y

#sudo apt-get install pip
sudo pip install barman

sudo -u postgres psql -U postgres -d postgres -c "alter user postgres with password '$POSTGRES_USERPASS';"

sudo su root -c "echo 'host    all             all             10.1.1.11/29             md5' >> /etc/postgresql/9.3/main/pg_hba.conf"

sudo sed -i s/"#wal_level = minimal'"/"wal_level = archive"/g /etc/postgresql/9.3/main/postgresql.conf
sudo sed -i s/"#archive_mode = off'"/"archive_mode = on"/g /etc/postgresql/9.3/main/postgresql.conf
sudo sed -i s/"#archive_command = ''"/"archive_command = 'rsync -a %p barman@$BACKUP_IP:/var/lib/barman/main/incoming/%f'"/g /etc/postgresql/9.3/main/postgresql.conf


sudo su postgres -c "ssh-keygen"
sudo su postgres -c "ssh-copy-id -i ~/.ssh/id_rsa.pub barman@$BACKUP_IP"

echo -e "\nPlease move to the barman backup machine and run install script give credentials below"
echo -e "\npostgres db user pass :$POSTGRES_USERPASS"
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




echo -e "\n >>>>>>>>>> PLEASE RESTART YOUR SERVER TO FINALISE THE INSTALLATION (See below for the command you should use) <<<<<<<<<<"
echo -e "\n---- restart the server (sudo shutdown -r now) ----"
while true; do
    read -p "Would you like to restart your server now (y/n)?" yn
    case $yn in
        [Yy]* ) sudo shutdown -r now
        break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done


