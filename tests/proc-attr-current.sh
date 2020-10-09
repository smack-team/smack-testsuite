#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

#
# Common tests for the two cases
#
function test_by_path() {
	TOTEST=$1
	LOOKPID=$BASHPID

	if ! echo Snap > $TOTEST ; then
		if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
		exit 1
	fi
	RC=`$TOOLS/get-file-smack.sh /proc/$LOOKPID/attr`
	[ "X$RC" = "XSnap" ] ; testcase $? $LINENO

	if ! echo Crackle > $TOTEST ; then
		if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
		exit 1
	fi
	RC=`$TOOLS/get-file-smack.sh /proc/$LOOKPID/attr`
	[ "X$RC" = "XCrackle" ] ; testcase $? $LINENO

	RC=`cat $TOTEST`
	[ "X$RC" = "XCrackle" ] ; testcase $? $LINENO

	su $NOTROOT -c "echo Pop > $TOTEST" >& /dev/null ; failcase $? $LINENO
}
#
# End of common tests for the two cases
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

SELINUX=`$TOOLS/has-lsm.sh selinux`

PASS=0
FAIL=0
#
# Test /proc/.../attr/smack/current iff it exists
#
if [ -f /proc/self/attr/smack/current ] ; then
	test_by_path "/proc/self/attr/smack/current" 
elif [ $VERBOSE = 1 ] ; then
	echo "Skipping attr/smack/current"
fi

#
# Test /proc/.../attr/current iff we're not running with SELinux
# Change this when prctl to set display lsm is available
#
if [ "X$SELINUX" != "Xselinux" ] ; then
	test_by_path "/proc/self/attr/current" 
elif [ $VERBOSE = 1 ] ; then
	echo "Skipping attr/current"
fi

#
# Test that /proc/self and /proc/<pid> get the same thing
#
if [ -f /proc/self/attr/smack/current ] ; then
	if ! echo Pop > /proc/self/attr/smack/current ; then
		if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
		exit 1
	fi
else
	if ! echo Pop > /proc/self/attr/current ; then
		if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
		exit 1
	fi
fi

OFSELF=`$TOOLS/get-file-smack.sh /proc/self/attr`
OFPID=`$TOOLS/get-file-smack.sh /proc/$BASHPID/attr`
[ "X$OFSELF" = "X$OFPID" -a "X$OFPID" = "XPop" ] ; testcase $? $LINENO

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
