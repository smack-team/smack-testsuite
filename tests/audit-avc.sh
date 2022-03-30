#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
LABEL=AuditAVC
ULABEL=UserLabel

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

$TOOLS/create-file-smack.sh $LABEL $TARGETS/$LABEL
if [ ! $? ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

PASS=0
FAIL=0
#
# Reset the audit log
#
$TOOLS/reset-auditd.sh

#
# The chsmack should fail, resulting in an AVC record.
#
$TOOLS/run-smack-user.sh $ULABEL $NOTROOT chsmack $TARGETS/$LABEL >& /dev/null
if [ ! $? ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

$TOOLS/find-audit-record.sh		\
	'.*fn=smack_inode_getxattr'	\
	'.*subject="' $ULABEL '"'	\
	'.*object="' $LABEL '"'		\
	'.* comm="chsmack"'		\
	'.* name="' $LABEL '"'
testcase $? $LINENO

#
# The ls -l should fail, resulting in an AVC record.
#
$TOOLS/run-smack-user.sh $ULABEL $NOTROOT ls -l $TARGETS/$LABEL >& /dev/null
if [ ! $? ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

$TOOLS/find-audit-record.sh		\
	'.*fn=smack_inode_getattr'	\
	'.*subject="' $ULABEL '"'	\
	'.*object="' $LABEL '"'		\
	'.* comm="ls"'
testcase $? $LINENO

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
