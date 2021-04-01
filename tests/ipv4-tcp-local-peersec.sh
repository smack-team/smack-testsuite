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
RFILE=$TARGETS/tcp-peersec
#
# clientbind server-smack client-smack line pass/fail
#
function clientbind {
	rm -f $RFILE
	sleep $NAPTIME
	$TOOLS/run-smack-root.sh $1 \
		$TOOLS/smack-ipv4-tcp-peersec >& $RFILE &

	sleep $NAPTIME
	echo $2 | $TOOLS/run-smack-root.sh $2 \
		socat - TCP:127.0.0.1:$TESTSOCK,connect-timeout=5 >& /dev/null

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

TESTSOCK=8000
PASS=0
FAIL=0
#
# 
#
clientbind Pop Pop $LINENO pass

$TOOLS/set-smack-rule.sh Peach Cream w
$TOOLS/set-smack-rule.sh Cream Peach -

clientbind Cream Peach $LINENO fail

$TOOLS/set-smack-rule.sh Peach Cream w
$TOOLS/set-smack-rule.sh Cream Peach w

clientbind Cream Peach $LINENO pass

$TOOLS/set-smack-rule.sh Peach Cream a
$TOOLS/set-smack-rule.sh Cream Peach a

clientbind Cream Peach $LINENO fail

$TOOLS/set-smack-rule.sh Peach Cream r
$TOOLS/set-smack-rule.sh Cream Peach r

clientbind Cream Peach $LINENO fail

$TOOLS/set-smack-rule.sh Peach Cream -
$TOOLS/set-smack-rule.sh Cream Peach -

clientbind Cream Peach $LINENO fail

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
