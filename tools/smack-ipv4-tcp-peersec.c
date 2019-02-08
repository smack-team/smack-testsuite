/*
 * Copyright (C) 2012 Casey Schaufler <casey@schaufler-ca.com>
 * Copyright (C) Intel Corporation.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <linux/ip.h>
#include <linux/udp.h>
#include <linux/netlink.h>
#include <sys/xattr.h>

#define BUFFER_SIZE	200
#define LOCAL_PORT	8000

int
main(int argc, char *argv[])
{
	int firstsock;
	int sock;
	struct sockaddr_in sin;
	struct sockaddr *sip = (struct sockaddr *)&sin;
	unsigned short local_port = LOCAL_PORT;
	int silen = sizeof(sin);
	int len;
	int i;
	int ipv = PF_INET;
	char peer[BUFFER_SIZE];

	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-p") == 0 ||
		    strcmp(argv[i], "--port") == 0)
			local_port = atoi(argv[++i]);
	}

	if ((firstsock = socket(ipv, SOCK_STREAM, IPPROTO_TCP)) < 0) { 
		perror("socket");
		exit(1);
	}

	bzero((char *)&sin, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_port = htons(local_port);
	sin.sin_addr.s_addr = INADDR_ANY;

	if (bind(firstsock, sip, silen) < 0) {
		printf("%s-bind\n", argv[0]);
		exit(1);
	}

	alarm(5);
	if (listen(firstsock, 0) < 0) {
		printf("%s-listen\n", argv[0]);
		exit(1);
	}

	len = silen;
	if ((sock = accept(firstsock, sip, &len)) < 0) {
		printf("%s-accept\n", argv[0]);
		exit(1);
	}

	len = sizeof(peer);
	if (getsockopt(sock, SOL_SOCKET, SO_PEERSEC, peer, &len) < 0) {
		printf("%s-getsockopt\n", argv[0]);
		exit(1);
	}
	printf("%s\n", peer);

	return 0;
}
