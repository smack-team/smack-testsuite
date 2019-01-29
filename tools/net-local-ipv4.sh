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

ADDRESS=`ifconfig | \
	grep 'inet ' | \
	grep -v 127.0.0.1 | \
	tail -1 | \
	sed -e 's/^[^i]*inet \([^ ]*\).*/\1/'`

if [ "X$ADDRESS" = "X" ]
then
	if [ $VERBOSE = 1 ] ; then echo 'No IPv4 address available' ; fi
	exit 1
fi

echo $ADDRESS
exit 0
