# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
PROGRAMS=	smack-proc-attr smackfs-access file-lock \
		smack-ipv4-udp-peersec \
		smack-ipv4-tcp-peersec

default: ${PROGRAMS}

clean:
	rm ${PROGRAMS}

smack-proc-attr: smack-proc-attr.c
	cc -o smack-proc-attr smack-proc-attr.c

smackfs-access: smackfs-access.c
	cc -o smackfs-access smackfs-access.c

file-lock: file-lock.c
	cc -o file-lock file-lock.c

smack-ipv4-udp-peersec: smack-ipv4-udp-peersec.c
	cc -o smack-ipv4-udp-peersec smack-ipv4-udp-peersec.c

smack-ipv4-tcp-peersec: smack-ipv4-tcp-peersec.c
	cc -o smack-ipv4-tcp-peersec smack-ipv4-tcp-peersec.c
