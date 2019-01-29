#! /bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
# run-smack-user [options] smack-label user cmd [args]

VERBOSE=0

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	DASH=`echo $1 | sed -e 's/\(.\).*/\1/'`
	if [ "X$DASH" != "X-" ] ;	then break ; fi
	shift
done

if [ $# -lt 3 ] ; then
	if [ $VERBOSE != 0 ] ; then
		echo "Expected smack, user or cmd missing."
	fi
	exit 1
fi

SMACK=$1	; shift
USERNAME=$1	; shift
COMMAND=$1	; shift

if [ -f /proc/self/attr/smack/current ] ; then
	echo $SMACK > /proc/self/attr/smack/current
elif [ -f /proc/self/attr/current ] ; then
	echo $SMACK > /proc/self/attr/current
else
	if [ $VERBOSE = 1 ] ; then
		echo "Cannot set process Smack - no current file."
	fi
	exit 1
fi

if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Setting $SMACK failed." ; fi
	exit 1
fi

if [ $VERBOSE = 1 ] ; then
	echo "Running as $USERNAME at $SMACK : $COMMAND $*"
fi
runuser -u $USERNAME -- $COMMAND $*
RESULT=$?

if [ $VERBOSE = 1 ] ; then echo "Exit of $COMMAND is $RESULT" ; fi
exit $RESULT
