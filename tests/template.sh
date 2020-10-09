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

PASS=0
FAIL=0
#
# All test scripts should include the above.
# 

#
# Look for a smackfs filesystem on /sys/fs/smackfs
#
mount | grep 'type smackfs' | grep -q '/sys/fs/smackfs'
testcase $? $LINENO

#
# Look for smack in the lsm list in /sys/kernel/security/lsm
#
RC=`$TOOLS/has-lsm.sh smack`
[ "X$RC" = "Xsmack" ] ; testcase $? $LINENO

#
# Look for a Smack label on the test directory
#
chsmack $TARGET/. >& /dev/null
testcase $? $LINENO

#
# Verify that the user process runs with the assigned Smack label
#
RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT $TOOLS/get-process-smack.sh`
[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

#
# All test scripts should include what follows
# 
# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
