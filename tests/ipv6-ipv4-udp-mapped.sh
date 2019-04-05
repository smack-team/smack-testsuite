#! /bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

#
# $1 - Smack value for the listener
# $2 - Smack value for the sender
# $3 - Port
# $4 - Host
# $5 - Calling line
# $6 - PASS/FAIL
#
function ipv6udpcase() {
	sleep $NAPTIME
	if [ $VERBOSE = 1 ] ; then
		echo $1 | $TOOLS/run-smack-user.sh $1 $NOTROOT \
			socat -u - UDP6-LISTEN:$3,reuseaddr &
	else
		echo $1 | $TOOLS/run-smack-user.sh $1 $NOTROOT \
			socat -u - UDP6-LISTEN:$3,reuseaddr >& /dev/null &
	fi

	sleep $NAPTIME
	TESTOUT=`echo $2 | $TOOLS/run-smack-user.sh $2 $NOTROOT \
			socat - UDP6:$4:$3`

	if [ $VERBOSE = 1 ] ; then
		echo $0: $6 '"'$1'"' '"'$TESTOUT'"'
	fi

	if [ "$6" = "PASS" ] ; then
		[ "X$TESTOUT" = "X$1" ]
	else
		[ ! "X$TESTOUT" = "X$1" ]
	fi
	testcase $? $5

	if [ ! "X$TESTOUT" = "X$2" ] ; then
		echo $1 | $TOOLS/run-smack-user.sh $1 $NOTROOT \
			socat - UDP6:$4:$3
	fi
}

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
TESTHOST="[::1]"
TESTPORT=8300

PASS=0
FAIL=0

ipv6udpcase Pop Pop $TESTPORT "[::1]" $LINENO PASS
ipv6udpcase Pop Pop $TESTPORT "[::ffff:127.0.0.1]" $LINENO PASS

$TOOLS/set-smack-rule.sh Snap Crackle w
$TOOLS/set-smack-rule.sh Crackle Snap w

ipv6udpcase Snap Crackle $TESTPORT "[::1]" $LINENO PASS
ipv6udpcase Snap Crackle $TESTPORT "[::ffff:127.0.0.1]" $LINENO PASS

$TOOLS/set-smack-rule.sh Snap Crackle -
$TOOLS/set-smack-rule.sh Crackle Snap -

$TOOLS/set-smack-rule.sh Eggs Bacon -
$TOOLS/set-smack-rule.sh Bacon Eggs w

ipv6udpcase Eggs Bacon $TESTPORT "[::1]" $LINENO FAIL
ipv6udpcase Eggs Bacon $TESTPORT "[::ffff:127.0.0.1]" $LINENO FAIL

$TOOLS/set-smack-rule.sh Eggs Bacon -
$TOOLS/set-smack-rule.sh Bacon Eggs -

ipv6udpcase Eggs Bacon $TESTPORT "[::1]" $LINENO FAIL
ipv6udpcase Eggs Bacon $TESTPORT "[::ffff:127.0.0.1]" $LINENO FAIL

$TOOLS/set-smack-rule.sh Oatmeal Granola w
$TOOLS/set-smack-rule.sh Granola Oatmeal -

ipv6udpcase Oatmeal Granola $TESTPORT "[::1]" $LINENO FAIL
ipv6udpcase Oatmeal Granola $TESTPORT "[::ffff:127.0.0.1]" $LINENO FAIL

$TOOLS/set-smack-rule.sh Oatmeal Granola -
$TOOLS/set-smack-rule.sh Granola Oatmeal -

ipv6udpcase Oatmeal Granola $TESTPORT "[::1]" $LINENO FAIL
ipv6udpcase Oatmeal Granola $TESTPORT "[::ffff:127.0.0.1]" $LINENO FAIL

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
