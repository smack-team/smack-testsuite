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

TESTHOST=`$TOOLS/net-local-ipv4.sh`
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then
		echo "$0 failed to get a local IPv4 address."
	fi
	exit 1
fi

NAPTIME=1
RFILE=$TARGETS/ipv4-udp-net-local-peersec
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
		socat - UDP:$TESTHOST:$TESTSOCK >& /dev/null

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
clientbind Tomotoes Tomotoes $LINENO pass

$TOOLS/set-smack-rule.sh Bangers Tomotoes w

clientbind Tomotoes Bangers $LINENO pass

$TOOLS/set-smack-rule.sh Bangers Tomotoes a

clientbind Tomotoes Bangers $LINENO fail

$TOOLS/set-smack-rule.sh Bangers Tomotoes r

clientbind Tomotoes Bangers $LINENO fail

$TOOLS/set-smack-rule.sh Bangers Tomotoes -

clientbind Tomotoes Bangers $LINENO fail

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
