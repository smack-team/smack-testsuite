#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

VERBOSE=0

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	shift
done

if [ -f /proc/self/attr/smack/current ] ; then
	CURR=/proc/self/attr/smack/current
elif [ -f /proc/self/attr/current ] ; then
	CURR=/proc/self/attr/current
else
	if [ $VERBOSE = 1 ] ; then
		echo "Cannot get process Smack - no current file."
	fi
	exit 1
fi

cat $CURR
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Fetching Smack failed." ; fi
	exit 1
fi
echo

exit 0
