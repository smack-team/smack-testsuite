# SPDX-License-Identifier: GPL-2.0-or-later
# Copyright (C) Intel Corporation, 2018
# Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
#
#
SHELL=/bin/bash
ROOT=.
TOOLS=${ROOT}/tools
TESTS=${ROOT}/tests
TARGETS=${ROOT}/targets

default:
	cat instructions.txt

#
# Ready to do the full suite
#
ready: has-smack has-chsmack has-ifconfig has-socat not-root net-local-ipv4
	make -C tools
#
# Ready to do the suite, but not going to the network
#
local-ready: has-smack has-chsmack has-ifconfig has-socat not-root
	make -C tools

setup: basic-setup

clean-targets:
	${TOOLS}/clean-targets.sh
is-root:
	${TOOLS}/is-root.sh
has-smack:
	${TOOLS}/has-lsm.sh smack
has-chsmack:
	${TOOLS}/has-chsmack.sh
has-socat:
	${TOOLS}/has-socat.sh
has-ifconfig:
	${TOOLS}/has-ifconfig.sh
not-root:
	${TOOLS}/not-root.sh >& /dev/null
net-local-ipv4:
	${TOOLS}/net-local-ipv4.sh >& /dev/null
net-local-ipv6:
	${TOOLS}/net-local-ipv6.sh >& /dev/null
basic-setup:
	${TOOLS}/basic-setup.sh
initialize-result:
	uname -s -r -v > result
	cat /sys/kernel/security/lsm >> result
	echo >> result

CASES-SMACK-API=	template proc-attr-current smackfs-access
CASES-FILESYSTEM=	file-access-positive file-access-negative file-locking \
			program-smack-exec dir-transmute mount
CASES-UDS=		uds-access
CASES-IPV4-LOCALHOST=	ipv4-tcp-localhost ipv4-udp-local-peersec \
			ipv4-tcp-localhost-access
CASES-IPV4-NET-LOCAL=	ipv4-tcp-net-local ipv4-udp-net-local-peersec \
			ipv4-tcp-net-local-access ipv4-tcp-local-peersec
CASES-IPV6-LOCALHOST=	ipv6-ipv4-udp-mapped ipv6-tcp-localhost \
			ipv6-tcp-localhost-access

CASES=	${CASES-SMACK-API} ${CASES-FILESYSTEM} ${CASES-UDS} \
	${CASES-IPV4-LOCALHOST} ${CASES-IPV4-NET-LOCAL} \
	${CASES-IPV6-LOCALHOST}

CASES-LOCAL=	${CASES-SMACK-API} ${CASES-FILESYSTEM} ${CASES-UDS} \
		${CASES-IPV4-LOCALHOST} \
		${CASES-IPV6-LOCALHOST}

test-results:	is-root ready setup clean-targets initialize-result ${CASES}
	${TOOLS}/final-report.sh

local-results:	is-root local-ready setup clean-targets initialize-result \
		${CASES-LOCAL}
	${TOOLS}/final-report.sh

#
# Test rules - always append to "result"
#
template:
	-${TESTS}/template.sh >> result
file-access-positive:
	-${TESTS}/file-access-positive.sh >> result
file-access-negative:
	-${TESTS}/file-access-negative.sh >> result
file-locking: clean-targets
	-${TESTS}/file-locking.sh 2> /dev/null >> result
program-smack-exec: tools/smack-proc-attr
	-${TESTS}/program-smack-exec.sh >> result
dir-transmute: clean-targets
	-${TESTS}/dir-transmute.sh >> result
mount: clean-targets
	-${TESTS}/mount.sh >> result
proc-attr-current:
	-${TESTS}/proc-attr-current.sh >> result
smackfs-access: tools/smackfs-access
	-${TESTS}/smackfs-access.sh >> result
uds-access: clean-targets
	-${TESTS}/uds-access.sh 2> /dev/null >> result
ipv4-udp-local-peersec: clean-targets
	-${TESTS}/ipv4-udp-local-peersec.sh 2> /dev/null >> result
ipv4-udp-net-local-peersec: clean-targets
	-${TESTS}/ipv4-udp-net-local-peersec.sh 2> /dev/null >> result
ipv4-tcp-localhost:
	-${TESTS}/ipv4-tcp-localhost.sh >> result
ipv4-tcp-localhost-access:
	-${TESTS}/ipv4-tcp-localhost-access.sh >> result
ipv4-tcp-net-local-access: net-local-ipv4
	-${TESTS}/ipv4-tcp-net-local-access.sh >> result
ipv4-tcp-local-peersec: net-local-ipv4
	-${TESTS}/ipv4-tcp-local-peersec.sh >> result
ipv4-tcp-net-local: net-local-ipv4
	-${TESTS}/ipv4-tcp-net-local.sh >> result
ipv6-ipv4-udp-mapped:
	-${TESTS}/ipv6-ipv4-udp-mapped.sh 2> /dev/null >> result
ipv6-tcp-localhost: net-local-ipv6
	-${TESTS}/ipv6-tcp-localhost.sh >> result
ipv6-tcp-localhost-access: net-local-ipv6
	-${TESTS}/ipv6-tcp-localhost-access.sh >> result
