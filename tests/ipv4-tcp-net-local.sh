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

TESTHOST=`$TOOLS/net-local-ipv4.sh`
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then
		echo "$0 failed to get a local IPv4 address."
	fi
	exit 1
fi
TESTPORT=8300

NAPTIME=1
PASS=0
FAIL=0
#
# 
#
ipv4tcpcase Pop Pop $LINENO pass

$TOOLS/set-smack-rule.sh Snap Crackle w
$TOOLS/set-smack-rule.sh Crackle Snap w

ipv4tcpcase Snap Crackle $LINENO pass

$TOOLS/set-smack-rule.sh Snap Crackle a
$TOOLS/set-smack-rule.sh Crackle Snap a

ipv4tcpcase Snap Crackle $LINENO fail

$TOOLS/set-smack-rule.sh Snap Crackle w
$TOOLS/set-smack-rule.sh Crackle Snap r

ipv4tcpcase Snap Crackle $LINENO fail

$TOOLS/set-smack-rule.sh Snap Crackle -
$TOOLS/set-smack-rule.sh Crackle Snap -

ipv4tcpcase Snap Crackle $LINENO fail

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
