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

$TOOLS/create-file-smack.sh Rice $TARGETS/file-deny-Rice
$TOOLS/create-file-smack.sh Crackle $TARGETS/file-deny-Crackle
$TOOLS/create-file-smack.sh Pop $TARGETS/file-deny-Pop

chown $NOTROOT $TARGETS/file-deny-Rice
chown $NOTROOT $TARGETS/file-deny-Crackle
chown $NOTROOT $TARGETS/file-deny-Pop
 
$TOOLS/set-smack-rule.sh Snap Crackle r
$TOOLS/set-smack-rule.sh Snap Pop w

PASS=0
FAIL=0
#
# Read Tests
#
$TOOLS/run-smack-user.sh Snap $NOTROOT \
	dd if=$TARGETS/file-deny-Rice of=/dev/null status=none >& /dev/null
failcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT \
	dd if=$TARGETS/file-deny-Pop of=/dev/null status=none >& /dev/null
failcase $? $LINENO

#
# Write Tests
#
$TOOLS/run-smack-user.sh Snap $NOTROOT dd status=none \
	of=$TARGETS/file-deny-Rice if=relative-common.include >& /dev/null
failcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT dd status=none \
	of=$TARGETS/file-deny-Crackle if=relative-common.include >& /dev/null
failcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT dd status=none \
	of=$TARGETS/file-deny-Pop if=relative-common.include >& /dev/null
failcase $? $LINENO

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
