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

$TOOLS/create-file-smack.sh Crackle $TARGETS/file-lock-Crackle
$TOOLS/create-file-smack.sh Pop $TARGETS/file-lock-Pop

chown $NOTROOT $TARGETS/file-lock-Crackle
chown $NOTROOT $TARGETS/file-lock-Pop
 
$TOOLS/set-smack-rule.sh Snap Pop w
LOCKERWAIT=5

PASS=0
FAIL=0
#
# Smack labels match
#
# Read lock taken by the 1st process, read lock taken by the 2nd process
TESTFILE=$TARGETS/file-lock-Pop
$TOOLS/run-smack-user.sh Pop $NOTROOT $TOOLS/file-lock $TESTFILE $LOCKERWAIT r &
LOCKER=$!
$TOOLS/run-smack-user.sh Pop $NOTROOT $TOOLS/file-lock $TESTFILE 0 r
testcase $? $LINENO
kill $LOCKER >& /dev/null

# Read lock taken by the 1st process, write lock taken by the 2nd process
$TOOLS/run-smack-user.sh Pop $NOTROOT $TOOLS/file-lock $TESTFILE $LOCKERWAIT r &
LOCKER=$!
$TOOLS/run-smack-user.sh Pop $NOTROOT $TOOLS/file-lock $TESTFILE/ 0 w
failcase $? $LINENO
kill $LOCKER >& /dev/null

#
# Access by the 2nd process allowed by a read rule
#
$TOOLS/set-smack-rule.sh Snap Crackle r
TESTFILE=$TARGETS/file-lock-Crackle
$TOOLS/run-smack-user.sh Crackle $NOTROOT \
	$TOOLS/file-lock $TESTFILE $LOCKERWAIT r &
LOCKER=$!
$TOOLS/run-smack-user.sh Snap $NOTROOT $TOOLS/file-lock $TESTFILE 0 r
failcase $? $LINENO
kill $LOCKER >& /dev/null

$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/file-lock $TESTFILE $LOCKERWAIT r &
LOCKER=$!
$TOOLS/run-smack-user.sh Snap $NOTROOT $TOOLS/file-lock $TESTFILE 0 w
failcase $? $LINENO
kill $LOCKER >& /dev/null

#
# Access by the 2nd process allowed by a read+lock rule
#
$TOOLS/set-smack-rule.sh Snap Crackle rl
TESTFILE=$TARGETS/file-lock-Crackle
$TOOLS/run-smack-user.sh Crackle $NOTROOT \
	$TOOLS/file-lock $TESTFILE $LOCKERWAIT r &
LOCKER=$!
$TOOLS/run-smack-user.sh Snap $NOTROOT $TOOLS/file-lock $TESTFILE 0 r
testcase $? $LINENO
kill $LOCKER >& /dev/null

$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/file-lock $TESTFILE $LOCKERWAIT r &
LOCKER=$!
$TOOLS/run-smack-user.sh Snap $NOTROOT $TOOLS/file-lock $TESTFILE 0 w
failcase $? $LINENO
kill $LOCKER >& /dev/null

#
# Access by the 2nd process allowed by a read+write rule
#
$TOOLS/set-smack-rule.sh Snap Crackle rw
TESTFILE=$TARGETS/file-lock-Crackle
$TOOLS/run-smack-user.sh Crackle $NOTROOT \
	$TOOLS/file-lock $TESTFILE $LOCKERWAIT r &
LOCKER=$!
$TOOLS/run-smack-user.sh Snap $NOTROOT $TOOLS/file-lock $TESTFILE 0 r
testcase $? $LINENO
kill $LOCKER >& /dev/null

$TOOLS/run-smack-user.sh Snap $NOTROOT \
	$TOOLS/file-lock $TESTFILE $LOCKERWAIT r &
LOCKER=$!
$TOOLS/run-smack-user.sh Snap $NOTROOT $TOOLS/file-lock $TESTFILE 0 w
failcase $? $LINENO
kill $LOCKER >& /dev/null

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi
exit 0
