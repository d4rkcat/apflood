#!/bin/bash


#Color formatters
RED=$(echo -e "\e[1;31m")
BLU=$(echo -e "\e[1;36m")
GRN=$(echo -e "\e[1;32m")
RST=$(echo -e "\e[0;0;0m")

clear 
printf $GRN"\nAccess Point Spammer - Flood Area with Fake Access Points\n"$RST
printf $GRN"To get started, let's get some information first"$RST


#read wireless card name
printf $BLU"\nEnter your Network Interface Card: "$RST
read CARD_NAME

#ask for mangle or not
printf $BLU"\nWould you like to use the mangler (y/n)? \nEnter (y) for mangler and (n) for ESSID file: "$RST
read MANGLER 

#branch on mangler or not
if [ $MANGLER = "y" ]; then
	printf $BLU"Enter the word you would like to mangle : "$RST
	read MANGLE_WORD
else
	#read access point file name/location
	printf $BLU"Enter the path to you ESSID file: "$RST
	read ESSID_FILE
	if [ ! -e $ESSID_FILE ]; then
		printf $RED"[-] File does not exist.. exiting\n"$RST
		exit
	fi
fi 

#continue our processing, seems like all is ok



printf $GRN"\nThe NIC is "$RST$BLU"$CARD_NAME"$RST
printf $GRN"\nThe essid file location is "$RST$BLU"$ESSID_FILE"$RST
printf $GRN"\nMangler flag is set to "$RST$BLU"$MANGLER\n"$RST
printf $GRN"\nThe word to be mangles flag is set to "$RST$BLU"$MANGLER\n"$RST


printf "\n"





