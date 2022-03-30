#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2022
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2022
#

VERBOSE=0
while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
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

if [ -f /var/run/auditd.pid ] ; then
	AUDITDPID=`cat /var/run/auditd.pid`
else
	AUDITDPID=`ps -e | grep auditd | grep -v kauditd`
	if [ $? != 0 ] ; then
		if [ $VERBOSE = 1 ] ; then
			echo 'There is no audit daemon running.'
		fi
		exit 1
	fi
	AUDITDPID=`echo $AUDITDPID | sed -e 's/  *\([0-9]*\).*/\1/'`
fi

kill -USR1 $AUDITDPID
RC=$?

if [ $RC != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Cannot signal auditd." ; fi
fi

if [ ! -f /var/log/audit/audit.log ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Missing audit log file." ; fi
	exit 1
fi

exit $RC
