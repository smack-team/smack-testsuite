# SPDX-License-Identifier: BSD-3-Clause
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
PROGRAMS= smack-proc-attr smackfs-access file-lock

default: ${PROGRAMS}

clean:
	rm ${PROGRAMS}

smack-proc-attr: smack-proc-attr.c
	cc -o smack-proc-attr smack-proc-attr.c

smackfs-access: smackfs-access.c
	cc -o smackfs-access smackfs-access.c

file-lock: file-lock.c
	cc -o file-lock file-lock.c
