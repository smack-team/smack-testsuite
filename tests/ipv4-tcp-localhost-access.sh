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

#
# Required by ipv4tcpcase:
#
NOTROOT=`$TOOLS/not-root.sh`
if [ ! $? ] ; then
	if [ $VERBOSE = 1 ] ; then echo "$0:$LINENO" ; fi
	exit 1
fi
NAPTIME=1
TESTHOST=LOCALHOST
TESTPORT=8300

PASS=0
FAIL=0

$TOOLS/set-smack-rule.sh Herring Toast -

ipv4tcpcase Herring Herring $LINENO pass
ipv4tcpcase Herring Toast $LINENO fail
ipv4tcpcase Herring _ $LINENO fail

# Report
echo $0 PASS=$PASS FAIL=$FAIL

if [ $FAIL != 0 ] ; then exit 1 ; fi

exit 0
