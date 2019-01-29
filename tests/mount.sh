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

if ! mkdir $TARGETS/mnt ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

SELINUX=`$TOOLS/has-lsm.sh selinux`

PASS=0
FAIL=0
#
#
if ! mount -t tmpfs -o size=512m tmpfs $TARGETS/mnt ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi
RC=`chsmack $TARGETS/mnt | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "X_" ] ; testcase $? $LINENO
umount $TARGETS/mnt

if ! mount -t tmpfs -o size=512m,smackfsroot="Pop" tmpfs $TARGETS/mnt ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi
RC=`chsmack $TARGETS/mnt | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "XPop" ] ; testcase $? $LINENO
umount $TARGETS/mnt

if [ $SELINUX = "-" ] ; then
	# Report
	echo $0 PASS=$PASS FAIL=$FAIL
	if [ $FAIL != 0 ] ; then exit 1 ; fi
	exit 0
fi

if [ $VERBOSE = 1 ] ; then echo "Extended with SELinux." ; fi
#
# These cases will only be run if SELinux is also enabled
#
mount -t tmpfs -o size=512m,seclabel tmpfs $TARGETS/mnt
testcase $? $LINENO
umount $TARGETS/mnt

if ! mount -t tmpfs -o size=512m,seclabel,smackfsroot="Pop" tmpfs $TARGETS/mnt
then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi

RC=`chsmack $TARGETS/mnt | sed -e 's/.*access="\([^"]*\).*/\1/'`
[ "X$RC" = "XPop" ] ; testcase $? $LINENO
umount $TARGETS/mnt

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
