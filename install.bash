#!/bin/bash
HEIGHT=17
CHOICE_HEIGHT=9
WIDTH=96
BACKTITLE="Simple installer"
TITLE="[ Traffic Watch Installer ]"
MENU="Create symbolic link or copy the script:"

OPTIONS=(
SymLink   'sudo ln -s $(pwd)/traffic-watch.bash /usr/local/bin/traffic-watch'
Copy      'sudo cp $(pwd)/traffic-watch.bash /usr/local/bin/traffic-watch'
+ ' '
StatusCMD 'Create local status shortcut: traffic-watch-status'
+ ' '
Remove       'sudo rm -f /usr/local/bin/traffic-watch'
+ ' '
LocalStatus  'cat /tmp/traffic-watch-*.log'
RemoteStatus 'ssh user@host.or.ip tail -n3 /tmp/traffic-watch-INTERFACE.log'
)

CHOICE=$(whiptail --clear \
    --backtitle "$BACKTITLE" \
    --title "$TITLE" \
    --menu "$MENU" \
    $HEIGHT $WIDTH $CHOICE_HEIGHT \
    "${OPTIONS[@]}" \
    2>&1 >/dev/tty)

clear
case $CHOICE in
    SymLink)
        sudo chmod +x "$(pwd)/traffic-watch.bash"
        sudo ln -s "$(pwd)/traffic-watch.bash" "/usr/local/bin/traffic-watch"
	printf '\n\nNow you can use "traffic-watch" as shell command\n\n'
        ;;

    Copy)
        sudo chmod +x "$(pwd)/traffic-watch.bash"
        sudo cp "$(pwd)/traffic-watch.bash" "/usr/local/bin/traffic-watch"
	printf '\n\nNow you can use "sudo -b traffic-watch LIMIT INTERFACE" as shell command\n\n'
        ;;

    StatusCMD)
	printf '\n#!/bin/sh\ncat /tmp/traffic-watch-*.log\n' | sudo tee "/usr/local/bin/traffic-watch-status"
	sudo chmod +x "/usr/local/bin/traffic-watch-status"
	printf '\n\nNow you can use "sudo -b traffic-watch LIMIT INTERFACE" as shell command\n\n'
        ;;

    Remove)
	sudo rm -f "/usr/local/bin/traffic-watch" "/usr/local/bin/traffic-watch-status" >/dev/null 2>&1
        ;;

    LocalStatus)
	cat "/tmp/traffic-watch-*.log"
        ;;

    RemoteStatus)
        printf '\nTo check the status remotely, use the following command:\n'
	printf '\n\tuser@host.or.ip tail -n3 /tmp/traffic-watch-INTERFACE.log\n'
	printf '\nReplace "user@host.or.ip" and "INTERFACE" with the actual value in use.\n\n'
        ;;

esac




