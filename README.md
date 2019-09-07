# Luke's Auto-Rice Bootstraping Scripts for DEBIAN (LARBS)
![alt text](https://raw.githubusercontent.com/fherking/LARBS/master/larbs-debian.jpg)

Just a proof of concept...
I wanted to know how hard would it be to port all the distro to debian (short answer, just a couple of days)
USE AT YOUR OWN RISK

Tested in vmware virtual machine (it works!!)

for more info: 

	https://github.com/LukeSmithxyz/voidrice

## Installation:

Install a machine with image debian-10.0.0-amd64-netinst.iso, do a minimal install, and create an user.

login as root

type the following:

	apt-get -y install curl
	curl -LO https://raw.githubusercontent.com/fherking/LARBS/master/debian/larbs.sh && sh larbs.sh
	
follow instructions:

after installing sudo the first time (not default on debian) you'll need to logout and login again, please follow on screen instructions and  exec the following after login as root again:

	sh larbs.sh
	
To proceed with second part of installation.	

After installation, login as user:

important: win key + f1  shows on screen manual (READ IT, BECAUSE YOU WONT KNOW WHAT TO DO)
