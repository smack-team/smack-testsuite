#! /bin/bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
# set-smack-rule [options] subject object access

LOAD2="/sys/fs/smackfs/load2"

VERBOSE=0

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	DASH=`echo $1 | sed -e 's/\(.\).*/\1/'`
	if [ "X$DASH" != "X-" ] ;	then break ; fi
	shift
done

if [ $# -lt 3 ] ; then
	if [ $VERBOSE != 0 ] ; then
		echo "Expected subject, object or access missing."
	fi
	exit 1
fi

SUBJECT=$1
OBJECT=$2
ACCESS=$3

if [ ! -f $LOAD2 ] ; then
	if [ $VERBOSE = 1 ] ; then
		echo "Cannot create rule - no load2 file."
	fi
	exit 1
fi

echo $SUBJECT $OBJECT $ACCESS > $LOAD2
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Creating rule failed." ; fi
	exit 1
fi

exit 0
