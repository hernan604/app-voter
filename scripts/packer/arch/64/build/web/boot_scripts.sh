SERVICE="rc-local.service"
FILE="/usr/lib/systemd/system/$SERVICE"
INIT_SCRIPT="/etc/rc.local"

cat <<COMMANDS > $FILE
[Unit]
Description=$INIT_SCRIPT Compatibility

[Service]
Type=oneshot
ExecStart=$INIT_SCRIPT
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
COMMANDS

#$(cat boot_scripts_wi.sh)
#COMMANDS="
#cd ~/perl/Web-IRC/WI-Main && sh start &
#cd ~/perl/Web-IRC/WI-WWW-Mojo && sh start &
#cd ~/perl/Web-IRC/WI-IRC && sh start_server.sh &
#"
#sudo su - vagrant -c "$COMMANDS"

cat <<'INIT_SCRIPT_CONTENT' > $INIT_SCRIPT
#!/usr/bin/env bash

echo boot time: `date` >> /home/vagrant/debug
sudo su - vagrant -c "cd ~/perl/app-voter/Voter-REST/ ; ./hypnotoad.sh"
#sudo su - vagrant -c "cd ~/perl ; ./init_script.sh start"


#WORKS sudo su - vagrant -c "/home/vagrant/perl/init_script.sh 2>> /home/vagrant/errors; /home/vagrant/perl/init_script.sh >> /home/vagrant/errors"

exit 0
INIT_SCRIPT_CONTENT

chmod +x $INIT_SCRIPT
systemctl enable $SERVICE
