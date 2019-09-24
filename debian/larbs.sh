#!/bin/sh
# Luke's Auto Rice Boostrapping Script (LARBS)
# by Luke Smith <luke@lukesmith.xyz>
# License: GNU GPLv3
# "adapted" to debian by <fernando.filgueira@gmail.com>
apt-get update
# DEFAULTS:
[ -z "$dotfilesrepo" ] && dotfilesrepo="https://github.com/fherking/voidrice.git" && repobranch="archi3"
[ -z "$progsfile" ] && progsfile="https://raw.githubusercontent.com/fherking/LARBS/master/debian/progs.csv"
[ -z "$repobranch" ] && repobranch="master"

### FUNCTIONS ###

error() { clear; printf "ERROR:\\n%s\\n" "$1"; exit;}

welcomemsg() { \

	dialog --title "Welcome!" --msgbox "Welcome to Fernando's Auto-Rice Bootstrapping Script!\\nThis work is based on original work done by Luke Smith <luke@lukesmith.xyz>\\n\\nThis script will automatically install a fully-featured i3wm Debian Linux desktop." 10 60
	}

getuserandpass() { \
	# Prompts user for new username an password.
	name=$(dialog --inputbox "First, please enter a name for the user account." 10 60 3>&1 1>&2 2>&3 3>&1) || exit
	while ! echo "$name" | grep "^[a-z_][a-z0-9_-]*$" >/dev/null 2>&1; do
		name=$(dialog --no-cancel --inputbox "Username not valid. Give a username beginning with a letter, with only lowercase letters, - or _." 10 60 3>&1 1>&2 2>&3 3>&1)
	done
	pass1=$(dialog --no-cancel --passwordbox "Enter a password for that user." 10 60 3>&1 1>&2 2>&3 3>&1)
	pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	while ! [ "$pass1" = "$pass2" ]; do
		unset pass2
		pass1=$(dialog --no-cancel --passwordbox "Passwords do not match.\\n\\nEnter password again." 10 60 3>&1 1>&2 2>&3 3>&1)
		pass2=$(dialog --no-cancel --passwordbox "Retype password." 10 60 3>&1 1>&2 2>&3 3>&1)
	done ;}

usercheck() { \
	! (id -u "$name" >/dev/null) 2>&1 ||
	dialog --colors --title "WARNING!" --yes-label "CONTINUE" --no-label "No wait..." --yesno "The user \`$name\` already exists on this system. LARBS can install for a user already existing, but it will \\Zboverwrite\\Zn any conflicting settings/dotfiles on the user account.\\n\\nLARBS will \\Zbnot\\Zn overwrite your user files, documents, videos, etc., so don't worry about that, but only click <CONTINUE> if you don't mind your settings being overwritten.\\n\\nNote also that LARBS will change $name's password to the one you just gave." 14 70
	}

preinstallmsg() { \
	dialog --title "Let's get this party started!" --yes-label "Let's go!" --no-label "No, nevermind!" --yesno "The rest of the installation will now be totally automated, so you can sit back and relax.\\n\\nIt will take some time, but when done, you can relax even more with your complete system.\\n\\nNow just press <Let's go!> and the system will begin installation!" 13 60 || { clear; exit; }
	}

adduserandpass() { \
	# Adds user `$name` with password $pass1.
	dialog --infobox "Adding user \"$name\"..." 4 50
	/usr/sbin/groupadd wheel
	/usr/sbin/useradd -m -g wheel -s /bin/bash "$name" >/dev/null 2>&1 ||
	/usr/sbin/usermod -a -G wheel "$name" && mkdir -p /home/"$name" && chown "$name":wheel /home/"$name"
	echo "$name:$pass1" | /usr/sbin/chpasswd
	unset pass1 pass2 ;}
	
modifysudoPass1(){
me=$(basename "$0")
groups | sed 's/ /\n/g' | grep sudo
if [ $? = 1 ]
then
	usermod -a -G sudo root
	usermod -a -G sudo $name
	echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
	clear
	echo "sudo rules has been modified, please logout and login again as root to apply groups permissions and execute $PWD/$me again to continue installation."
	exit
fi

}

finalsudorights(){
#restore sudo rights
echo "Defaults        env_reset" > /etc/sudoers
echo "Defaults        mail_badpass ">> /etc/sudoers
echo "Defaults        secure_path=\"/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\"" >> /etc/sudoers

echo "%sudo ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/systemctl suspend,/usr/bin/wifi-menu,/usr/bin/mount,/usr/bin/umount,/usr/bin/packer -Syu,/usr/bin/packer -Syyu,/usr/bin/systemctl restart NetworkManager,/usr/bin/rc-service NetworkManager restart,/usr/bin/loadkeys,/usr/bin/yay" >> /etc/sudoers
}

newperms() { # Set special sudoers settings for install (or after).
	sed -i "/#LARBS/d" /etc/sudoers
	echo "$* #LARBS" >> /etc/sudoers ;
	
	}



maininstall() { # Installs all needed programs from main repo.
	
	apt-get install -y -q "$1" 
	
	}


stinstall() {
	clear
	dir=/home/$name/build/st
	git clone --depth 1 https://github.com/fherking/st.git $dir
	cd $dir
	make make 
	make install 
}

dmenuinstall() {
	dir=/home/$name/build/dmenu
	git clone --depth 1 https://github.com/fherking/dmenu.git $dir
	cd $dir
	make make 
	make install 
}
	
gitmakeinstall() {
	dir=$(mktemp -d)
#	dialog --title "LARBS Installation" --infobox "Installing \`$(basename "$1")\` ($n of $total) via \`git\` and \`make\`. $(basename "$1") $2" 5 70
	git clone --depth 1 "$1" "$dir"
	cd "$dir" || exit
	make
	make install
	echo "press a key" ; read key
	}

pipinstall() { \
	#dialog --title "LARBS Installation" --infobox "Installing the Python package \`$1\` ($n of $total). $1 $2" 5 70
	#apt-get install -y -q python-pip 
	pip3 install "$1"
	
	}

installsc_im(){
	echo "istalando im"
	apt-get -y -q install libzip-dev libxml2-dev bison  libncurses5-dev libncursesw5-dev
	apt-get -y -q install stow
	
	tempdir=/home/$name/build/sc-im
	sudo -u "$name" git clone https://github.com/fherking/sc-im  $tempdir 
	sed -i 's/prefix=\/usr/prefix=\/usr\/local\/stow\/sc-im/g' "$tempdir/src/Makefile"
	sed -i 's/DFLT_PAGER := -DDFLT_PAGER=\"less\"/DFLT_PAGER := -DDFLT_PAGER=\"pager\"/g'  "$tempdir/src/Makefile"
	sed -i 's/foo/bar/g'  "$tempdir/src/Makefile"
	sed -i 's/YACC := bison -y/YACC := bison -y/g'  "$tempdir/src/Makefile"
	sed -i 's/XLSX :=/#XLSX :=/g'  "$tempdir/src/Makefile"
	sed -i 's/#XLSX := -DXLSX/XLSX := -DXLSX/g'  "$tempdir/src/Makefile"
	sed -i 's/LDLIBS := -lm -lncurses/LDLIBS := -lm -lncursesw -lzip -lxml2/g'  "$tempdir/src/Makefile"
	sudo -u "$name" make -C   "$tempdir/src" 
	sudo make install -C "$tempdir/src"
	
}	

install_xcbutil(){
	echo "istalando i3 xcb utils"
	tempdir=/home/$name/build/xcp-utils
	sudo -u "$name" git clone https://github.com/fherking/xcb-util-xrm  $tempdir 
	cd $tempdir
	git submodule update --init
	./autogen.sh --prefix=/usr
	make
	sudo make install
	
}

install_i3gaps(){
clear
	echo "istalando i3 gaps"
	apt-get -y -q install libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf xutils-dev libtool automake  libxcb-xrm-dev libxcb-shape0-dev 
	
	install_xcbutil
	
	tempdir=/home/$name/build/i3-gaps
	
	#	/usr/sbin/sudo -u "$name"
	git clone https://www.github.com/fherking/i3  $tempdir 
	
	cd $tempdir
	git checkout gaps && git pull
	autoreconf --force --install
	rm -rf build
	mkdir build
	cd build
	../configure --prefix=/usr --sysconfdir=/etc --disable-sanitizers
	make
	make install
	
}


installationloop() { \
	([ -f "$progsfile" ] && cp "$progsfile" /tmp/progs.csv) || curl -Ls "$progsfile" | sed '/^#/d' > /tmp/progs.csv
	total=$(wc -l < /tmp/progs.csv)
	#aurinstalled=$(pacman -Qm | awk '{print $1}')
	while IFS=, read -r tag program comment; do
		n=$((n+1))
		echo "$comment" | grep "^\".*\"$" >/dev/null 2>&1 && comment="$(echo "$comment" | sed "s/\(^\"\|\"$\)//g")"
		case "$tag" in
			"") maininstall "$program" "$comment" ;;
			"G") gitmakeinstall "$program" "$comment" ;;
			"P") pipinstall "$program" "$comment" ;;
		esac
	done < /tmp/progs.csv ;
	
	}

putgitrepo() { # Downlods a gitrepo $1 and places the files in $2 only overwriting conflicts
	#dialog --infobox "Downloading and installing config files..." 4 60
	[ -z "$3" ] && branch="master" || branch="$repobranch"
	dir=$(mktemp -d)
	[ ! -d "$2" ] && mkdir -p "$2" && chown -R "$name:wheel" "$2"
	chown -R "$name:wheel" "$dir"
	sudo -u "$name" git clone -b "$branch" --depth 1 "$1" "$dir/gitrepo" 
	sudo -u "$name" cp -rfT "$dir/gitrepo" "$2"
	
	}

serviceinit() { for service in "$@"; do
	dialog --infobox "Enabling \"$service\"..." 4 40
	systemctl enable "$service"
	systemctl start "$service"
	done ;
	
	}

systembeepoff() { dialog --infobox "Getting rid of that retarded error beep sound..." 10 50
	rmmod pcspkr
	#remove echo "blacklist pcspkr" > /etc/modprobe.d/nobeep.conf ;
	}

resetpulse() { dialog --infobox "Reseting Pulseaudio..." 4 50
	pkill pulseaudio
	sudo -n "$name" pulseaudio --start ;
	
	}

finalize(){ \
	dialog --infobox "Preparing welcome message..." 4 50
	echo "exec_always --no-startup-id notify-send -i ~/.local/share/larbs/larbs.png 'Welcome to LARBS:' 'Press Super+F1 for the manual.' -t 10000"  >> "/home/$name/.config/i3/config"
	dialog --title "All done!" --msgbox "Congrats! Provided there were no hidden errors, the script completed successfully and all the programs and configuration files should be in place.\\n\\nTo run the new graphical environment, log out and log back in as your new user, then run the command \"startx\" to start the graphical environment (it will start automatically in tty1).\\n\\n.t Luke" 12 80
	
	}

### THE ACTUAL SCRIPT ###

### This is how everything happens in an intuitive format and order.

# Check if user is root on debian distro. Install dialog.

#install sudo and dialog



apt-get install -y -q dialog sudo  ||  error "Are you sure you're running this as the root user? Are you sure you're using an Debian 10 - based distro? ;-) Are you sure you have an internet connection? Are you sure your Arch keyring is updated?"

#fix for dialog 
export NCURSES_NO_UTF8_ACS=1

# Welcome user.
welcomemsg || error "User exited."

# Get and verify username and password.
getuserandpass || error "User exited."

# Give warning if user already exists.
usercheck || error "User exited."

# Last chance for user to back out before install.
preinstallmsg || error "User exited."

### The rest of the script requires no user input.

adduserandpass || error "Error adding username and/or password."

modifysudoPass1

dialog --title "LARBS Installation" --infobox "Installing \`basedevel\` and \`git\` for installing other software." 5 70

apt-get install -y -q build-essential git 

# The command that does all the installing. Reads the progs.csv file and
# installs each needed program the way required. Be sure to run this only after
# the user has been created and has priviledges to run sudo without a password
# and all build dependencies are installed.

#bien
installationloop
installsc_im
install_i3gaps
pip3 install ueberzug

putgitrepo "$dotfilesrepo" "/home/$name" "$repobranch"

dmenuinstall

stinstall

rm -f "/home/$name/README.md" "/home/$name/LICENSE"

serviceinit NetworkManager

finalsudorights

updatedb

reboot
