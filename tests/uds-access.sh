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

if [ -f ./relative-common.include ] ; then
	. ./relative-common.include
else
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi
. $TESTS/test-functions.include

if ! $TOOLS/is-root.sh ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

NOTROOT=`$TOOLS/not-root.sh`
if [ ! $? ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

NAPTIME=1
#
# clientbind server-smack client-smack line pass/fail
#
function clientbind {
	sleep $NAPTIME
	echo $2 | \
		$TOOLS/run-smack-user.sh $1 $NOTROOT \
			socat - UNIX-LISTEN:$TESTSOCK >& /dev/null &
	SOCAT=$!
	sleep $NAPTIME
	echo $1 | \
		$TOOLS/run-smack-user.sh $2 $NOTROOT \
			socat - UNIX-CONNECT:$TESTSOCK >& /dev/null
	RC=$?
	if [ "X$4" = "Xfail" ] ; then
		failcase $RC $3
	else
		testcase $RC $3
	fi

	# Clean up any socats that are lingering.
	if [ -S $TESTSOCK ]
	then
		fuser --kill -s $TESTSOCK
		rm -f $TESTSOCK
	fi
}

mkdir $TARGETS/uds-notroot
chown $NOTROOT $TARGETS/uds-notroot
chsmack -a '*' $TARGETS/uds-notroot
TESTSOCK=$TARGETS/uds-notroot/uds-access-socket

PASS=0
FAIL=0
#
# 
#
clientbind Pop Pop $LINENO pass

$TOOLS/set-smack-rule.sh Snap Crackle w
$TOOLS/set-smack-rule.sh Crackle Snap w

clientbind Snap Crackle $LINENO pass

$TOOLS/set-smack-rule.sh Snap Crackle a
$TOOLS/set-smack-rule.sh Crackle Snap a

clientbind Snap Crackle $LINENO fail

$TOOLS/set-smack-rule.sh Snap Crackle w
$TOOLS/set-smack-rule.sh Crackle Snap r

clientbind Snap Crackle $LINENO fail

$TOOLS/set-smack-rule.sh Snap Crackle -
$TOOLS/set-smack-rule.sh Crackle Snap -

clientbind Snap Crackle $LINENO fail

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
