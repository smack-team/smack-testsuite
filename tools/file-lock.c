/*
 * SPDX-License-Identifier: GPL-2.0-or-later
 * Copyright (C) Intel Corporation, 2018
 * Copyright (C) Casey Schaufler <casey@schaufler-ca.com> 2018
 *
 */
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>

/*
 * testlock path time mode
 */
int main(int argc, char *argv[])
{
	/* l_type   l_whence  l_start  l_len  l_pid   */
	struct flock fl = {F_WRLCK, SEEK_SET, 0, 0, 0};
	int fd;
	char *path;
	int delay;
	char *mode;
	int o;
	time_t before;
	time_t after;

	if (argc != 4) {
#ifdef DEBUG
		fprintf(stderr, "%s requires three arguments.\n", argv[0]);
#endif
		exit(1);
	}
	path = argv[1];
	delay = atoi(argv[2]);
	mode = argv[3];
	if (*mode == 'r') {
		fl.l_type = F_RDLCK;
		o = O_RDONLY;
	} else if (*mode == 'w') {
		fl.l_type = F_WRLCK;
		o = O_RDWR;
	} else {
#ifdef DEBUG
		fprintf(stderr, "%s bad mode %s.\n", argv[0], argv[3]);
#endif
		exit(1);
	}

	fl.l_pid = getpid();

	if ((fd = open(path, o)) == -1) {
#ifdef DEBUG
		perror("open");
#endif
		exit(1);
	}

	before = time(NULL);
	if (fcntl(fd, F_SETLKW, &fl) == -1) {
#ifdef DEBUG
		perror("lock fcntl");
#endif
		exit(1);
	}
	after = time(NULL) - before;

	if (delay)
		sleep(delay);
#ifdef DEBUG
	else
		fprintf(stdout, "testlock:%d %s locked %d.\n",
			fl.l_pid, mode, after);
#endif


	fl.l_type = F_UNLCK;  /* set to unlock same region */
#ifdef DEBUG
	if (fcntl(fd, F_SETLK, &fl) == -1)
		perror("unlock fcntl");
#endif

	if (delay == 0 && after != 0)
		exit(1);

	exit(0);
}
