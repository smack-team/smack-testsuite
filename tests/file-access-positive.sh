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

$TOOLS/create-file-smack.sh Snap $TARGETS/file-allow-Snap
$TOOLS/create-file-smack.sh Crackle $TARGETS/file-allow-Crackle
$TOOLS/create-file-smack.sh Pop $TARGETS/file-allow-Pop

chown $NOTROOT $TARGETS/file-allow-Snap
chown $NOTROOT $TARGETS/file-allow-Crackle
chown $NOTROOT $TARGETS/file-allow-Pop
 
$TOOLS/set-smack-rule.sh Snap Crackle r
$TOOLS/set-smack-rule.sh Snap Pop rw

PASS=0
FAIL=0
#
# Read Tests
#
$TOOLS/run-smack-user.sh Snap $NOTROOT \
	dd if=$TARGETS/file-allow-Snap of=/dev/null status=none
testcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT \
	dd if=$TARGETS/file-allow-Crackle of=/dev/null status=none
testcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT \
	dd if=$TARGETS/file-allow-Pop of=/dev/null status=none
testcase $? $LINENO

#
# Write Tests
#
$TOOLS/run-smack-user.sh Snap $NOTROOT \
	dd status=none of=$TARGETS/file-allow-Snap if=relative-common.include
testcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT \
	dd status=none of=$TARGETS/file-allow-Pop if=relative-common.include
testcase $? $LINENO

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
