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

ID=`id -u`
if [ $ID != 0 ]
then
	if [ $VERBOSE = 1 ] ; then echo 'UID' $ID 'is not root.' ; fi
	exit 1
fi

exit 0
