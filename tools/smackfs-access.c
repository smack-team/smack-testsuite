/* SPDX-License-Identifier: BSD-3-Clause */
/*
 * testaccess - See if /smack/access and /smack/access2 work
 *
 * Copyright (C) 2007 Casey Schaufler <casey@schaufler-ca.com>
 * Copyright (C) 2011 Intel Corporation.
 *
 *      This program is free software; you can redistribute it and/or modify
 *      it under the terms of the GNU General Public License as published by
 *      the Free Software Foundation, version 2.
 *
 *	This program is distributed in the hope that it will be useful, but
 *	WITHOUT ANY WARRANTY; without even the implied warranty of
 *	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 *	General Public License for more details.
 *
 *	You should have received a copy of the GNU General Public
 *	License along with this program; if not, write to the Free Software
 *	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 *	02110-1301 USA
 *
 * Authors:
 *      Casey Schaufler <casey@schaufler-ca.com>
 *
 * Prints the status charactor for the access.
 *	'1' - the access would be allowed
 *	'0' - the access would not be allowed
 *	    - anything else indicates an error,
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char line[1024];

char writenread(int fd, char *sp, char *op, char *ap, char *fmt)
{
	char back[2];
	int rc;

	back[0] = '\0';
	back[1] = '\0';

	sprintf(line, fmt, sp, op, ap);
	if ((rc = write(fd, line, strlen(line)+1)) < 0)
		return 'W';
	if ((rc = read(fd, back, 2)) < 0)
		return 'R';
	if (rc != 2)
		return 'S';
	if (back[1] != '\0')
		return 'T';
	if (back[0] == '\0')
		return 'N';
	if (back[0] == '1' || back[0] == '0')
		return back[0];
	return '?';
}

int
main(int argc, char *argv[])
{
	int fd;
	char c;

	if (argc != 5)
		exit(1);

	if (strcmp("access", argv[1]) == 0) {
		if ((fd = open("/sys/fs/smackfs/access", O_RDWR)) < 0)
			exit(1);
		c = writenread(fd, argv[2], argv[3], argv[4],
			       "%-23s %-23s %-5s");
	} else if (strcmp("access2", argv[1]) == 0) {
		if ((fd = open("/sys/fs/smackfs/access2", O_RDWR)) < 0)
			exit(1);
		c = writenread(fd, argv[2], argv[3], argv[4], "%s %s %s");
	} else
		exit(1);

	printf("%c\n", c);
	if (c == '1' || c == '0')
		exit(0);
	exit(1);
}
