#! /bin/bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
# has-lsm module
LSMFILE=/sys/kernel/security/lsm

VERBOSE=0
while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	DASH=`echo $1 | sed -e 's/\(.\).*/\1/'`
	if [ "X$DASH" != "X-" ] ;	then break ; fi
	shift
done

if [ $# -ne 1 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "LSM name not provided." ; fi
	exit 1
fi

if [ ! -f $LSMFILE ] ; then
	if [ $VERBOSE = 1 ] ; then echo "System lacks LSM support." ; fi
	exit 1
fi

if cat $LSMFILE | sed -e 's/\(.*\)/,\1,/' | grep -qi ','$1',' ; then
	echo $1
else
	echo '-'
	exit 1
fi
exit 0
