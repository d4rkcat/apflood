#!/bin/bash


#Color formatters
RED=$(echo -e "\e[1;31m")
BLU=$(echo -e "\e[1;36m")
GRN=$(echo -e "\e[1;32m")
RST=$(echo -e "\e[0;0;0m")

fbssid(){
	printf $GRN"[+] Generating BSSIDs ... Please wait.."$RST
	BSSID_LIST=()
	
	#Generate Random MAC Addresses For Our Access Points
	for ((i = 0; i <= $NUM_OF_ESSIDS; i++))
	do
		BSSID_LIST[$i]=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//')
	done
		
	#write out bssids to tmp file
	for i in "${BSSID_LIST[@]}"
	do
		#printf $i"\n"
		echo $i >> BSSID_FILE
	done
	
	
		
}


fapflood(){
	
	#set region to Bolivia - makes power boosting possible
	printf $GRN"\n[+] Starting monitor mode "$RST
	
	iw reg set BO > /dev/null
	printf $GRN"\n[+] Changing MAC and attempting to boost power on "$RST$BLU$NIC$RST
	ifconfig $NIC down > /dev/null
	macchanger -a $NIC > /dev/null
	iwconfig $NIC mode monitor > /dev/null
	ifconfig $NIC up > /dev/null
	
	printf $GRN"\n[+] Started monitor mode on "$RST$BLU$NIC$RST
	printf "\n"
	printf $GRN"\n[+] The area is now flooded with your APs "$RST
	printf $GRN"\n[+] Press Ctrl+C to stop the flooding and exit "$RST
	printf $GRN"Open the logfile to check the logs for output of the script"
	
	#use this for WPA2 setups	
	#airbase-ng -i $NIC -Z 2 -I 10 -c 1 -P --essids $ESSID_FILE --bssids BSSID_FILE -x 200 $NIC -F FRAMES_FILE > /dev/null
	
	#use this for open setups
	airbase-ng -i $NIC -I 10 -c 6 -P --essids $ESSID_FILE --bssids BSSID_FILE -x 200 $NIC -F FRAMES_FILE >> logfile
	
	
	
	
	
	
	
}

fmangle()																#Mangle a word and get 30 permutations
{
	if [ $MANGLE_WORD -z ] 2> /dev/null
	then
		read -p $BLU"[+] Please enter the word to mangle: "$RED MANGLE_WORD
	fi
	echo $GRN"[+] Mangling $RED$MANGLE_WORD$GRN.."
	LEN=$(echo $MANGLE_WORD | wc -c)
	LEN=$((LEN - 1))
	crunch $LEN $LEN 01 -o binmap 2> /dev/null
	BINMAP=$(cat binmap | head -n 30)
	rm binmap
	rm mangled 2> /dev/null
	LETTERS="$(echo -e $MANGLE_WORD | sed 's/\(.\)/\1\n/g')"
	PLACE=0
	for PATTERN in $BINMAP
	do
		PATMAP="$(echo -e $PATTERN | sed 's/\(.\)/\1\n/g' | head -n -1)"
		for BIT in $PATMAP
		do
			SPLACE=$((PLACE + 1))
			LET=$(echo "$LETTERS" | sed -n "$SPLACE"p)
			if [ $BIT = 1 ] 2> /dev/null
			then
				echo ${LET^} >> onemang
			else
				echo $(echo $LET | tr '[:upper:]' '[:lower:]') >> onemang
			fi
			PLACE=$((PLACE + 1))
		done
		
		if [ $PLACE -ge $LEN ] 2> /dev/null
		then
			PLACE=0
			cat onemang >> mangled
			echo \ >> mangled
			rm onemang
		fi
	done

	SORT=$(cat mangled | tr -d '\n')
	echo "$SORT" | tr ' ' '\n' | tail -n +1 | uniq | head -n -1 > mangled
	MANGLED_FILE='mangled'
}
	
fexit()																	#Clean temp files and exit
{
	echo
	rm -rf tmpe 2> /dev/null
	rm bssids 2> /dev/null
	rm mangled 2> /dev/null
	killall -9 airbase-ng 2> /dev/null
	airmon-ng stop $MON1 | grep fff
	echo $RED" [*] $MON1 has been shut down,$GRN Goodbye...$RST"
	exit
}


fprompts(){
	clear 
	printf $GRN"\n*****Access Point Spammer - Flood Area with Fake Access Points*****\n"$RST
	printf $GRN"***To get started, let's get some information firs\***\n"$RST
	
	
	#read wireless card name
	printf $BLU"\n[+] Enter your Network Interface Card: "$RST
	read NIC
	
	#ask for mangle or not
	printf $BLU"\n[+] Would you like to use the"$RST$RED" Mangler "$RST$BLU"(y/n)?"$RST$BLU"\nEnter "$RST$GRN"(y)"$RST$BLU" for mangler and "$RST$RED"(n)"$RST$BLU" for ESSID file: "$RST
	read MANGLER 
	
	#branch on mangler or not
	if [ $MANGLER = "y" ]; then
		#printf $BLU"[+] Enter the word you would like to mangle : "$RST
		#read MANGLE_WORD
		fmangle
		ESSID_FILE=$MANGLED_FILE
		NUM_OF_ESSIDS=$(wc -l < $ESSID_FILE)
		fbssid
		fapflood
	else
		#read access point file name/location
		printf $BLU"\n[+] Enter the path to you ESSID file: "$RST
		read ESSID_FILE
		if [ ! -e $ESSID_FILE ]; then
			printf $RED"[-] File does not exist.. exiting\n"$RST
			exit
		else
			NUM_OF_ESSIDS=$(wc -l < $ESSID_FILE)
			fbssid
			fapflood
		fi
	fi 
}



#Prompt for user inputs
fprompts 



