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

if [ $VERBOSE = 1 ] ; then
	which chsmack
else
	which chsmack >& /dev/null
fi

if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "No chsmack command found." ; fi
	exit 1
fi

chsmack -r . >& /dev/null
if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo 'No chsmack "-r" option.' ; fi
	exit 1
fi


if [ $VERBOSE = 1 ] ; then
	which smackload
else
	which smackload >& /dev/null
fi

if [ $? != 0 ] ; then
	if [ $VERBOSE = 1 ] ; then echo "No smackload command found." ; fi
	exit 1
fi

exit 0
