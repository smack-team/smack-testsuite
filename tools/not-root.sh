#! /bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

VERBOSE=0
CONFIG=config
while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	if [ "$1" = "-c" -o "$1" = "--config" ] ; then
		if [ $# -lt 2 ] ; then
			echo "The -c/--config option requires a path."
			exit 1
		fi
		CONFIG=$2
		shift
	fi
	shift
done

if [ ! -f $CONFIG ] ; then
	echo The specified config file \"$CONFIG\" is not a file.
	exit 1
fi

USERNAME=`grep notroot= $CONFIG | sed -e 's/notroot=//'`
if [ "X$USERNAME" = "X" ] ; then
	if [ $VERBOSE = 1 ] ; then echo "No notroot= line in $CONFIG." ; fi
	exit 1
fi

if [ $VERBOSE = 1 ] ; then
	grep $USERNAME /etc/passwd
else
	grep -q $USERNAME /etc/passwd
fi

if [ $? = 0 ] ; then
	echo $USERNAME
	exit 0
fi

if [ $VERBOSE = 1 ] ; then echo "No entry in /etc/passwd for $USERNAME." ; fi
exit 1
