#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2022
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2022
#

AFILE=/var/log/audit/audit.log
RC=0
VERBOSE=0
LOOKFOR=""

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ; then
		VERBOSE=1
	else
		LOOKFOR="$LOOKFOR""$1"
	fi
	shift
done

if [ -f ./relative-common.include ] ; then
	. ./relative-common.include
else
	if [ $VERBOSE = 1 ] ; then echo "Cannot find environment." ; fi
	exit 1
fi

if ! $TOOLS/is-root.sh ; then
	if [ $VERBOSE = 1 ] ; then echo "Not root." ; fi
	exit 1
fi

if [ ! -f $AFILE ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Missing audit log file." ; fi
	exit 1
fi

if [ "$LOOKFOR" = "" ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Nothing to look for." ; fi
	exit 1
fi

if [ $VERBOSE = 1 ] ; then
	grep "$LOOKFOR" $AFILE
else
	grep "$LOOKFOR" $AFILE >& /dev/null
fi
RC=$?

exit $RC
