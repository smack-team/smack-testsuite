#! /bin/sh
# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

VERBOSE=0
CONFIG="config"
SETTING=""
while [ $# != 0 ] ; do
	if [ "$1" = "--verbose" -o "$1" = "-v" ] ; then VERBOSE=1 ; fi
	if [ "$1" = "--config" -o "$1" = "-c" ] ; then
		if [ $# -lt 2 ] ; then
			echo "The --config/-c option requires a path."
			exit 1
		fi
		CONFIG=$2
		shift
	fi
	if [ "$1" = "--setting" -o "$1" = "-s" ] ; then
		if [ $# -lt 2 ] ; then
			echo "The --setting/-s option requires a value."
			exit 1
		fi
		SETTING=$2
		shift
	fi
	shift
done

KERNELPATH=`grep kernel-config= $CONFIG | sed -e 's/kernel-config=//'`
if [ "X$KERNELPATH" = "X" ] ; then
	if [ $VERBOSE = 1 ] ; then
		echo "No kernel-config= line in $CONFIG."
	fi
	exit 1
fi

if [ "X$SETTING" != "X" ] ; then
	if grep -q "$SETTING is not set" $KERNELPATH ; then
		if [ $VERBOSE = 1 ] ; then echo "$SETTING is not set" ; fi
		exit 1
	fi
	RESULT=`grep "^$SETTING=" $KERNELPATH`
	if [ $? != 0 ]; then
		if [ $VERBOSE = 1 ] ; then echo "$SETTING not found" ; fi
		exit 1
	fi
	echo $RESULT | sed -e 's/^[^=]*=//'
	exit 0
fi

echo $KERNELPATH
exit 0
