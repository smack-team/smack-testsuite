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

$TOOLS/create-file-smack.sh -d Snap $TARGETS/Snap-dir
$TOOLS/create-file-smack.sh -d Snap $TARGETS/Snap-dir-t
chown $NOTROOT $TARGETS/Snap-dir
chown $NOTROOT $TARGETS/Snap-dir-t
chsmack -t $TARGETS/Snap-dir-t

$TOOLS/create-file-smack.sh -d Crackle $TARGETS/Crackle-dir
$TOOLS/create-file-smack.sh -d Crackle $TARGETS/Crackle-dir-t
chown $NOTROOT $TARGETS/Crackle-dir
chown $NOTROOT $TARGETS/Crackle-dir-t
chsmack -t $TARGETS/Crackle-dir-t

$TOOLS/create-file-smack.sh -d Pop $TARGETS/Pop-dir
$TOOLS/create-file-smack.sh -d Pop $TARGETS/Pop-dir-t
chown $NOTROOT $TARGETS/Pop-dir
chown $NOTROOT $TARGETS/Pop-dir-t
chsmack -t $TARGETS/Pop-dir-t

$TOOLS/set-smack-rule.sh Snap Crackle rwx
$TOOLS/set-smack-rule.sh Snap Pop rwxt

PASS=0
FAIL=0
#
# Tests without a transmute attribute on the directory.
#
$TOOLS/run-smack-user.sh Snap $NOTROOT mkdir $TARGETS/Snap-dir/x
RC=`chsmack $TARGETS/Snap-dir/x | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT mkdir $TARGETS/Crackle-dir/x
RC=`chsmack $TARGETS/Crackle-dir/x | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT mkdir $TARGETS/Pop-dir/x
RC=`chsmack $TARGETS/Pop-dir/x | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

#
# Tests with a transmute attribute on the directory.
#
$TOOLS/run-smack-user.sh Snap $NOTROOT mkdir $TARGETS/Snap-dir-t/x
RC=`chsmack $TARGETS/Snap-dir-t/x | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT mkdir $TARGETS/Crackle-dir-t/x
RC=`chsmack $TARGETS/Crackle-dir-t/x | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

$TOOLS/run-smack-user.sh Snap $NOTROOT mkdir $TARGETS/Pop-dir-t/x
RC=`chsmack $TARGETS/Pop-dir-t/x | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "XPop" ] ; testcase $? $LINENO

#
# Test that the transmute bit is correct on the new directories
#
RC=`chsmack $TARGETS/Snap-dir-t/x | sed -e 's/.*transmute="TRUE".*/OK/'`
[ "X$RC" != "XOK" ] ; testcase $? $LINENO

RC=`chsmack $TARGETS/Snap-dir/x | sed -e 's/.*transmute="TRUE".*/OK/'`
[ "X$RC" != "XOK" ] ; testcase $? $LINENO

RC=`chsmack $TARGETS/Crackle-dir-t/x | sed -e 's/.*transmute="TRUE".*/OK/'`
[ "X$RC" != "XOK" ] ; testcase $? $LINENO

RC=`chsmack $TARGETS/Crackle-dir/x | sed -e 's/.*transmute="TRUE".*/OK/'`
[ "X$RC" != "XOK" ] ; testcase $? $LINENO

# This in the different one
RC=`chsmack $TARGETS/Pop-dir-t/x | sed -e 's/.*transmute="TRUE".*/OK/'`
[ "X$RC" = "XOK" ] ; testcase $? $LINENO

RC=`chsmack $TARGETS/Pop-dir/x | sed -e 's/.*transmute="TRUE".*/OK/'`
[ "X$RC" != "XOK" ] ; testcase $? $LINENO

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
