#!/bin/bash

RESET="\e[0m"
YELLOW="\e[33m"
BOLD="\e[1m"
RED="\e[31m"
GREEN='\033[0;36m'
BLUE='\033[1;32m'
BLUEB='\033[30;106m'

err() {
    echo -e "${RED}[-]${RESET} ${@}"
    exit 1
}

warn() {
    echo -e "${YELLOW}[!]${RESET} ${@}"
}

msg() {
    echo -e "${GREEN}[+]${RESET} ${@}"
}

info() {
    echo -e "${BLUE}[*]${RESET} ${@}"
}

bn() {
echo -e "${YELLOW}
-----------------------------------------

       _        __                _     _
      | |      / _|              (_)   | |
__   _| | __ _| |_ _ __ ___   ___ _ ___| |_ ___ _ __
\ \ / / |/ _` |  _| '_ ` _ \ / _ \ / __| __/ _ \ '__|
 \ V /| | (_| | | | | | | | |  __/ \__ \ ||  __/ |
  \_/ |_|\__,_|_| |_| |_| |_|\___|_|___/\__\___|_|


Twitter:  @vlafmeister
Moded: by Secven

${YELLOW}-----------------------------------------${RESET}"
}

[ $UID != 0 ] && err "Must be run as root, Script terminating. ${GREEN}'sudo ./$(basename ${0})'${RESET}"

bn

path="/etc/grub.d/40_custom"

edit_grub () {

	if [[ $1 -eq 1 ]]
	then
		sed -i.bak -e '/^$/d' -e '/^set.*$/d' -e '/^password.*$/d' $path
		temp=$(file /boot/grub/grub.cfg.bak)
		ch=$(echo $?)

		if [[ $ch -eq 0 ]]
		then
			rm /boot/grub/grub.cfg.bak
		fi

		temp=$(file $path.bak)
		ch=$(echo $?)

		if [[ $ch -eq 0 ]]
		then
			rm $path.bak
		fi
	else
		info "${GREEN}Enter username: ${RESET}"
		read username
		sed -i.bak -e '/^$/d' -e '/^set.*$/d' -e '/^password.*$/d' $path
		printf "\nset superusers=\"%s\"\n" "$username" >> $path
		printf "password_pbkdf2 %s %s\n" "$username" "$str" >> $path
		cp /boot/grub/grub.cfg /boot/grub/grub.cfg.bak
	fi

    info "${GREEN}Wait config update...${RESET}"
    grub-mkconfig -o /boot/grub/grub.cfg &> /dev/null
	sleep 2
	info "${GREEN}Protect 40_custom for only root${RESET}"
	chmod 711 /etc/grub.d/40_custom
	sleep 2
	info "${GREEN}Protect Grub Finish !!!${RESET}"
}

func_init() {

if [[ $1 == --help ]]
then
	echo "./grub_passwd.sh [option]"
	printf "\tOption :\n\t\t-e\tEdit grub loader\n\t\t-r\tremove grub password\n"
	exit 0
elif [[ $1 == -r ]]
then
	edit_grub 1
	exit 0
fi

info "${GREEN}You see the password for GRUB${RESET}"
echo -n "Enter password: "
read -s passwd1
echo ""
echo -n "Reenter password: "
read -s passwd2
echo ""

if [[ $passwd1 == $passwd2 ]] && [[ -n $passwd1 ]] &&  [[ -n $passwd2 ]]
then
	temp=$(mktemp)
	printf "%s\n%s" "$passwd1" "$passwd2" > $temp
	str=$(grub-mkpasswd-pbkdf2 < $temp)
	rm -r $temp
	str=${str:68}
	len=$(wc -c $path | sed 's/\s.*$//')

	if [[ $len -gt 214 ]]
	then
		info "${GREEN}Grub is already configure do want to edit (y/n/default):${RESET}"
		read choice
		if [[ $choice == y ]]
		then
			edit_grub
		else
			exit 0
		fi
	else
		edit_grub
	fi
else
	err "${RED}grub-mkpasswd-pbkdf2: error: passwords don't match.${RESET}"
fi

exit 0

}
