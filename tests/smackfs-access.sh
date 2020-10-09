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

$TOOLS/set-smack-rule.sh Snap Crackle rx

PASS=0
FAIL=0
#
# Test /sys/fs/smackfs/access
#
RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/smackfs-access access Snap Snap rwxat`
[ "X$RC" = "X1" ] ; testcase $? $LINENO

RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/smackfs-access access Snap Crackle rx`
[ "X$RC" = "X1" ] ; testcase $? $LINENO

RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/smackfs-access access Snap Crackle w`
[ "X$RC" = "X0" ] ; testcase $? $LINENO

#
# Test /sys/fs/smackfs/access2
#
RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/smackfs-access access2 Snap Snap rwxat`
[ "X$RC" = "X1" ] ; testcase $? $LINENO

RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/smackfs-access access2 Snap Crackle rx`
[ "X$RC" = "X1" ] ; testcase $? $LINENO

RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/smackfs-access access2 Snap Crackle w`
[ "X$RC" = "X0" ] ; testcase $? $LINENO

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
