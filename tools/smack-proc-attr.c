/*
 * SPDX-License-Identifier: BSD-3-Clause
 * Copyright (C) Intel Corporation, 2018
 * Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
 *
 */
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

#define SMACK_LABEL	256

int main(int argc, char *argv[])
{
	char smack[SMACK_LABEL];
	int fd;
	int i;
	char *cp;

	fd = open("/proc/self/attr/smack/current", O_RDONLY);
	if (fd < 0)
		fd = open("/proc/self/attr/current", O_RDONLY);
	if (fd < 0)
		exit(1);

	i = read(fd, smack, SMACK_LABEL-1);
	if (i >= 0)
		smack[i] = '\0';
	if ((cp = strchr(smack, '\n')) != NULL)
		*cp = '\0';
	printf("%s\n", smack);

	exit(0);
}
