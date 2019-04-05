#! /bin/bash
# SPDX-License-Identifier: BSD-3-Clause
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

if [ -f $RULESTORE ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Rule store $RULESTORE exists." ; fi
	exit 1
fi

cat $LOAD2 > $RULESTORE
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Cannot copy rules." ; fi
	exit 1
fi

exit 0
