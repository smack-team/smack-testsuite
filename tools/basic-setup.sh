#! /bin/bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

VERBOSE=0

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	shift
done

if [ ! -c /dev/null ] ; then
	if [ $VERBOSE = 1 ] ; then echo "There is no /dev/null." ; fi
	exit 1
fi

NULLSMACK=`chsmack /dev/null | sed -e 's/.*access="\([^"]*\)".*/\1/'`
if [ "X$NULLSMACK" != 'X*' ] ; then
	if [ $VERBOSE = 1 ] ; then echo Reset `chsmack /dev/null`; fi
	if ! chsmack -a '*' /dev/null ; then
		if [ $VERBOSE = 1 ] ; then
			echo "Cannot set '*' on /dev/null."
		fi
		exit 1
	fi
fi

exit 0
