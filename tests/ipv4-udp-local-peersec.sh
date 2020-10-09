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
RFILE=$TARGETS/udp-peersec
#
# clientbind server-smack client-smack line pass/fail
#
function clientbind {
	sleep $NAPTIME
	rm -f $TARGETS/peersec
	$TOOLS/run-smack-root.sh $1 \
		$TOOLS/smack-ipv4-udp-peersec >& $RFILE &

	sleep $NAPTIME
	echo $2 | $TOOLS/run-smack-root.sh $2 \
		socat - UDP:127.0.0.1:$TESTSOCK >& /dev/null

	sleep $NAPTIME

	RESULT=`cat $RFILE`
	rm -f $RFILE

	if [ "X$2" = "X$RESULT" ] ; then RC=0 ; else RC=1; fi
        if [ "X$4" = "Xfail" ] ; then
                failcase $RC $3
        else
                testcase $RC $3
        fi
}

TESTSOCK=7000
PASS=0
FAIL=0
#
# 
#
clientbind Pop Pop $LINENO pass

$TOOLS/set-smack-rule.sh Crackle Snap w

clientbind Snap Crackle $LINENO pass

$TOOLS/set-smack-rule.sh Crackle Snap a

clientbind Snap Crackle $LINENO fail

$TOOLS/set-smack-rule.sh Crackle Snap r

clientbind Snap Crackle $LINENO fail

$TOOLS/set-smack-rule.sh Crackle Snap -

clientbind Snap Crackle $LINENO fail

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
