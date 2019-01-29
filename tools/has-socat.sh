#! /bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

VERBOSE=0
while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	shift
done

if [ $VERBOSE = 1 ] ; then
	which socat
else
	which socat >& /dev/null
fi

if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "No socat command found." ; fi
	exit 1
fi

exit 0
