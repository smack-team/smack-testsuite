#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

LOAD2="/sys/fs/smackfs/load2"

VERBOSE=0

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	shift
done

if [ -f ./relative-common.include ] ; then
	. ./relative-common.include
else
	if [ $VERBOSE = 1 ] ; then echo "Cannot find environment." ; fi
	exit 1
fi

if [ ! -f $LOAD2 ] ; then
	if [ $VERBOSE = 1 ] ; then
		echo "Cannot save rules - no load2 file."
	fi
	exit 1
fi

if [ ! -f $RULESTORE ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Rule store $RULESTORE missing." ; fi
	exit 1
fi

cat $LOAD2 > $TARGETS/restore-hold
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Cannot fetch rules." ; fi
	exit 1
fi

smackload --clear $TARGETS/restore-hold 
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Cannot clear rules." ; fi
	exit 1
fi

smackload $RULESTORE 
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Cannot restore rules." ; fi
	exit 1
fi

rm -f $RULESTORE
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Cannot remove $RULESTORE." ; fi
fi

exit 0
