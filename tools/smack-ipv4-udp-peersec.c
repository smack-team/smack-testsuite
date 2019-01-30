/*
 * Copyright (C) 2019 Casey Schaufler <casey@schaufler-ca.com>
 * Copyright (C) Intel Corporation.
 */

#include <arpa/inet.h>
#include <linux/ip.h>
#include <linux/netlink.h>
#include <linux/udp.h>
#include <linux/xattr.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/xattr.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define IP_PASSSEC	18
#define BUFFER_SIZE	500
#define LOCAL_PORT	7000
/*
 * This are found in linux/socket.h but the code here
 * needs sys/socket.h and they conflict.
 */
#ifndef SCM_SECURITY
#define SCM_SECURITY	0x03	/* rw: security label */
#endif

int smackrecvmsg(int sock, struct msghdr *msgp, int flags,
		 char *smack, int smacklen)
{
	struct cmsghdr *chp;
	char *cp;
	int len;
	int rc;

	rc = recvmsg(sock, msgp, flags);
	if (rc < 0)
		return rc;

	if (msgp->msg_controllen <= sizeof(struct cmsghdr))
		return rc;

	chp = CMSG_FIRSTHDR(msgp);

	if (chp->cmsg_type != SCM_SECURITY)
		return 2;

	cp = (char *) CMSG_DATA(chp);
	len = chp->cmsg_len - (cp - (char *)chp);
	if (len < 1)
		return 3;

	if (strlen(cp) >= smacklen)
		return 4;

	if (chp->cmsg_len >= smacklen)
		return 5;

	strcpy(smack, cp);
	return 0;
}


int
main(int argc, char *argv[])
{
	int sock;
	int i;
	int isone = 1;
	unsigned short local_port = LOCAL_PORT;
	char peer[BUFFER_SIZE];
	char buffer[BUFFER_SIZE];
	char control[BUFFER_SIZE];
	struct sockaddr_in sin;
	struct iovec iov = { buffer, sizeof(buffer) };
	struct msghdr message = {
		(void*)&sin, sizeof(sin), &iov, 1, control, BUFFER_SIZE, 0
	};

	for (i = 1; i < argc; i++) {
		if (strcmp(argv[i], "-p") == 0 ||
		    strcmp(argv[i], "--port") == 0)
			local_port = atoi(argv[++i]);
	}

	if ((sock = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) { 
		printf("%s-socket-failed\n", argv[0]);
		exit(1);
	}

	bzero((char *)&sin, sizeof(sin));
	sin.sin_family = AF_INET;
	sin.sin_port = htons(local_port);

	if (bind(sock, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
		printf("%s-bind-failed\n", argv[0]);
		exit(1);
	}

        if (setsockopt(sock, SOL_IP, IP_PASSSEC, &isone, sizeof(isone)) < 0) {
		printf("%s-setsockopt-failed\n", argv[0]);
		exit(1);
	}
  
	bzero((char *)&sin, sizeof(sin));
	bzero(buffer, BUFFER_SIZE);
	bzero(control, BUFFER_SIZE);
	message.msg_namelen = sizeof(sin);
	message.msg_controllen = BUFFER_SIZE;

	alarm(3);
	strcpy(peer, "smack-ipv4-udp-peersec-smackrecvmsg-void\n");
	i = smackrecvmsg(sock, &message, 0, peer, sizeof(peer));
	if (i < 0) {
		printf("%s-smackrecvmsg-failed\n", argv[0]);
		exit(1);
	}

	printf("%s\n", peer);
	close(sock);

	return 0;
}
