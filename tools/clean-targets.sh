#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
# clean-targets [options]

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

if ! $TOOLS/is-root.sh ; then
	if [ $VERBOSE = 1 ] ; then echo "Not root." ; fi
	exit 1
fi

if [ ! -d $TARGETS ] ; then
	mkdir -m 775 -p $TARGETS
fi

cd $TARGETS
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "Cannot find $TARGETS" ; fi
	exit 1
fi

rm -rf *

exit 0
