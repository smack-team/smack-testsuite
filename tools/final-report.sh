#! /bin/bash
# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#

VERBOSE=0
PRELIM="result"

while [ $# != 0 ] ; do
	if [ "$1" = "-v" -o "$1" = "--verbose" ] ;	then VERBOSE=1 ; fi
	DASH=`echo $1 | sed -e 's/\(.\).*/\1/'`
	if [ "X$DASH" != "X-" ] ;	then break ; fi
	shift
done

if [ $# != 0 ] ; then PRELIM="$1" ; fi

PSUM=`grep PASS= $PRELIM | sed -e 's/.*PASS=\([0-9]*\).*/\1 +/'`
PASS=`expr $PSUM 0`
FSUM=`grep FAIL= $PRELIM | sed -e 's/.*FAIL=\([0-9]*\).*/\1 +/'`
FAIL=`expr $FSUM 0`
TOTAL=`expr $PASS + $FAIL`
PASSRATE=`expr $PASS '*' 100 / $TOTAL`

echo $PASS Passed, $FAIL Failed, $PASSRATE'%' Success rate

exit 0
