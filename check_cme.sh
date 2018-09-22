#!/bin/bash

# les commandes
CMD_BASENAME="/usr/bin/basename"
CMD_SNMPGET="/usr/bin/snmpget"
CMD_SNMPWALK="/usr/bin/snmpwalk"


# nom de script
SCRIPTNAME=`$CMD_BASENAME $0`;

# version
VERSION="1.0"

# Copyrights
COPYRIGHTS="All Rights Reserved (c) Mohamed Chouchéne 2018"

# Retour de Plugin
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3


# OID
VOIP_NETWORK="1.3.6.1.4.1.9.9.439.1.1.4.0"

# variables par defaut
DESCRIPTION="Unknown"
STATE=$STATE_UNKNOWN

# options par defaut
COMMUNITY="public"
HOSTNAME="127.0.0.1"
WARNING=down
CRITICAL=unknown

# fonction pour afficher l'usage
print_usage() {
	echo "Usage: ./check_cme.sh -H 192.168.1.1 -C public"
	echo "  $SCRIPTNAME -H ADDRESS"
	echo "  $SCRIPTNAME -C STRING"
	echo "  $SCRIPTNAME -h"
	echo "  $SCRIPTNAME -V"
}

# fonction pour afficher la version
print_version() {
	echo $SCRIPTNAME version $VERSION
	echo ""
	echo $COPYRIGHTS
  echo ""
}

# fonction pour afficher l'aide
print_help() {
	print_version
	echo ""
	print_usage
	echo ""
	echo "Check the consummable of the printer"
	echo ""
	echo "-H ADDRESS"
	echo "   Name or IP address of host (default: 127.0.0.1)"
	echo "-C STRING"
	echo "   Community name for the host's SNMP agent (default: public)"
	echo "-h"
	echo "   Print this help screen"
	echo "-V"
	echo "   Print version and license information"
	echo ""
    echo ""
    echo $COPYRIGHTS
}

# traitement des options
while getopts H:C:h:v OPT
do
	case $OPT in

		H) HOSTNAME="$OPTARG" ;;
		C) COMMUNITY="$OPTARG" ;;
		h) 	print_help
		 	exit $STATE_UNKNOWN;;
		v)
			print_version
			exit $STATE_UNKNOWN ;;
		*) exit $STATE_UNKNOWN ;;

	esac
done

# affectation de variable "NETWORK" avec la sortie de commande "SNMPGET" 
NETWORK=$($CMD_SNMPGET -t 2 -r 2 -v 1 -c $COMMUNITY $HOSTNAME $VOIP_NETWORK)

# traitement de disponibilité de réseau voip précisé
if [[ $NETWORK =~ 0.0.0.0 ]]; then
	STATE=$STATE_CRITICAL
	DESCRIPTION="La VoIP ne marche pas !!"
elif [[ $NETWORK =~ $HOSTNAME ]]; then
	STATE=$STATE_OK
	DESCRIPTION="la VoIP marche correctement !!"
else
	STATE=$STATE_UNKNOWN
	DESCRIPTION="erreur inconnu !!"
fi

echo $DESCRIPTION
exit $STATE
