#!/bin/bash -x

local_backup_dir="/backup"
local_backup_filename="Backup_$(date +\%Y\%m\%d).tar.gz"
local_backup_file="$local_backup_dir/$local_backup_filename"

ssh_server="backup@ts"
ssh_backup_dir="/backup"

scp_user_host="backup@ts"

sufunc() {
  # sudo tar -czvf "$local_backup_file" /home/azubi 
  ssh "$ssh_server" "cd /backup/tk/day7; rm -rf *; mv /backup/tk/day6 /backup/tk/day7; mv /backup/tk/day5 /backup/tk/day6; mv /backup/tk/day4 /backup/tk/day5; mv /backup/tk/day3 /backup/tk/day4; mv /backup/tk/day2 /backup/tk/day3; mv /backup/tk/day1 /backup/tk/day2"
  rsync -av --delete --exclude={'/proc','/run','/sys','/dev','/backup','/tmp','/etc/shadow'} -e ssh / $ssh_server:/backup/tk/day  
# sudo tar --exclude=/backup --exclude=/dev --exclude=/tmp --exclude=/sys --exclude=/proc --exclude=/etc/shadow -czvf "$local_backup_file" /
  #if [ $? -eq 0 ]; then
  #  echo "Sudo erfolgreich ausgeführt"
  #else
  #  echo "Fehler beim Ausführen von Sudo"
  #  exit 1
  #fi
}

if ! mountpoint -q "$local_backup_dir"; then
  echo "Backup-Verzeichnis ist nicht gemounted! Es wird gemounted..."
  mount "$local_backup_dir"
  if [ $? -ne 0 ]; then
    echo "Fehler beim Mounten des lokalen Backup-Verzeichnisses!"
    echo "Exiting..."
    exit 1
  fi
fi

sufunc

ssh "$ssh_server" "mountpoint -q /$ssh_backup_dir"
if [ $? -ne 0 ]; then
  echo "SSH Backup-Verzeichnis ist nicht gemounted!"
  echo "Exiting..."
  exit 1
fi

echo "Backup erfolgreich erstellt: $local_backup_file"

#scp "$local_backup_file" "$scp_user_host":"$ssh_backup_dir"
if [ $? -eq 0 ]; then
  echo "Backup wurde erfolgreich auf den SSH-Server kopiert"
else
  echo "Fehler beim Kopieren des Backups auf den SSH-Server"
fi
