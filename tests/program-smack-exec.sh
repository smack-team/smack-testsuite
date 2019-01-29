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

#
# Copy the program so attributes can be set.
#
if [ ! -f $TOOLS/smack-proc-attr ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi
if [ -f $TARGETS/testbed-proc-attr ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

cp $TOOLS/smack-proc-attr $TARGETS/proc-attr-Snap
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi
chsmack -a Snap -e Pop $TARGETS/proc-attr-Snap
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

cp $TOOLS/smack-proc-attr $TARGETS/proc-attr-Crackle
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi
chsmack -a Crackle -e Pop $TARGETS/proc-attr-Crackle
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

$TOOLS/set-smack-rule.sh Snap Crackle rx

PASS=0
FAIL=0
#
# Tests with an execute attribute on the program.
#
RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT $TARGETS/proc-attr-Snap`
[ "X$RC" = "XPop" ] ; testcase $? $LINENO

RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT $TARGETS/proc-attr-Crackle`
[ "X$RC" = "XPop" ] ; testcase $? $LINENO

#
# Tests without an execute attribute on the program.
#
chsmack -E $TARGETS/proc-attr-Snap
chsmack -E $TARGETS/proc-attr-Crackle

RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT $TARGETS/proc-attr-Snap`
[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

RC=`$TOOLS/run-smack-user.sh Snap $NOTROOT $TARGETS/proc-attr-Crackle`
[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
