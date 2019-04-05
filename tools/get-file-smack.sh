#! /bin/bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
# get-file-smack file

VERBOSE=0

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	DASH=`echo $1 | sed -e 's/\(.\).*/\1/'`
	if [ "X$DASH" != "X-" ] ;	then break ; fi
	shift
done

if [ $# -ne 1 ] ; then
	if [ $VERBOSE != 0 ] ; then echo "Expected pathname missing." ; fi
	exit 1
fi

SMACK=`chsmack $1 | sed -e 's/.*access="\([^"]*\)".*/\1/'`
echo $SMACK
exit 0
