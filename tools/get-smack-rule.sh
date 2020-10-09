#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
# set-smack-rule [options] subject object

LOAD2="/sys/fs/smackfs/load2"

VERBOSE=0

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	DASH=`echo $1 | sed -e 's/\(.\).*/\1/'`
	if [ "X$DASH" != "X-" ] ;	then break ; fi
	shift
done

if [ $# -lt 2 ] ; then
	if [ $VERBOSE != 0 ] ; then
		echo "Expected subject or object missing."
	fi
	exit 1
fi

SUBJECT=$1
OBJECT=$2

if [ ! -f $LOAD2 ] ; then
	if [ $VERBOSE = 1 ] ; then
		echo "Cannot create rule - no load2 file."
	fi
	exit 1
fi

grep "^$SUBJECT $OBJECT" $LOAD2
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "No rule found." ; fi
	exit 1
fi

exit 0
