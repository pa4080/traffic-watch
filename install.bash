#!/bin/bash
HEIGHT=12
CHOICE_HEIGHT=4
WIDTH=90
BACKTITLE="Simple installer"
TITLE="[ Traffic Watch Installer ]"
MENU="Create symbolic link or copy the script:"

OPTIONS=(
SymLink   ' sudo ln -s $(pwd)/traffic-watch.bash /usr/local/bin/traffic-watch '
Copy      ' sudo cp $(pwd)/traffic-watch.bash /usr/local/bin/traffic-watch    '
Shell     " Back to CLI"
Remove    ' rm -f /usr/local/bin/traffic-watch'
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
        ;;

    Copy)
        sudo chmod +x "$(pwd)/traffic-watch.bash"
        sudo cp "$(pwd)/traffic-watch.bash" "/usr/local/bin/traffic-watch"
        ;;


    Shell)
        exit
        ;;
esac




