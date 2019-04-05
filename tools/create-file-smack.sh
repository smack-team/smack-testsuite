#! /bin/bash
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
# create-file-smack [options] smack-label path[ path]...

VERBOSE=0
DIRECTORY=0

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	if [ "$1" = "-d" -o "$1" = "--directory" ] ;	then DIRECTORY=1 ; fi
	DASH=`echo $1 | sed -e 's/\(.\).*/\1/'`
	if [ "X$DASH" != "X-" ] ;	then break ; fi
	shift
done

if [ $# -lt 2 ] ; then
	if [ $VERBOSE != 0 ] ; then
		echo "Expected smack and/or path missing."
	fi
	exit 1
fi

SMACK=$1 ; shift

while [ $# -gt 0 ] ; do
	if [ $DIRECTORY = 1 ] ; then
		DIR=$1
	else
		DIR=`dirname $1`
		FILE=`basename $1`
	fi
	mkdir -p $DIR
	if [ $? != 0 ] ; then
		if [ $VERBOSE = 1 ] ; then
			echo "Cannot create $DIR for $1."
		fi
		exit 1
	fi
	if [ $DIRECTORY = 0 ] ; then
		touch $1
		if [ $? != 0 ] ; then
			if [ $VERBOSE = 1 ] ; then echo "Cannot create $1." ; fi
			exit 1
		fi
	fi
	chsmack -r -a $SMACK $1
	if [ $? != 0 ] ; then
		if [ $VERBOSE = 1 ] ; then echo "Cannot set $SMACK on $1." ; fi
		exit 1
	fi
	shift
done

exit 0
