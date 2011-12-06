#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <sys/socket.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

#include "matsock.h"
#include <mex.h>


/* Error check macro */
#define ec(cmd) \
    do {\
        char ec_error_string_buf[128]; \
        sprintf(ec_error_string_buf, "%s (%d)", __FILE__, __LINE__); \
        if ((cmd) < 0) { \
            mexErrMsgTxt(ec_error_string_buf); \
        } \
    } \
    while (0)


static double ntohd(double x)
{
    double one = 1;
    if (*((char*) &one) == 0) {
        double tmp;
        char* src = (char*) &x;
        char* dst = (char*) &tmp;
        dst[0] = src[7];
        dst[1] = src[6];
        dst[2] = src[5];
        dst[3] = src[4];
        dst[4] = src[3];
        dst[5] = src[2];
        dst[6] = src[1];
        dst[7] = src[0];
        return tmp;
    } else {
        return x;
    }
}


static double htond(double x)
{
    return ntohd(x);
}


int matsock_new_tcp(const char* hostname, int port)
{
    int sockfd;                        /* socket file descriptor */
    struct sockaddr_in addr;           /* address information    */
    struct hostent* hp;                /* host information       */

    if ((hp = gethostbyname(hostname)) == NULL)
        mexErrMsgTxt("Unknown host");

    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    memcpy(&addr.sin_addr, hp->h_addr_list[0], hp->h_length);

    ec(sockfd = socket(AF_INET, SOCK_STREAM, 0));
    ec(connect(sockfd, (struct sockaddr*) &addr, sizeof(addr)));
    return sockfd;
}


int matsock_new_unix(const char* sockname)
{
    int sockfd;                           /* socket file descriptor */
    struct sockaddr_un addr;              /* my address information */
    int len;

    memset(&addr, 0, sizeof(addr));
    addr.sun_family = AF_UNIX;
    strcpy(addr.sun_path, sockname);
    len = sizeof(addr.sun_family) + strlen(addr.sun_path) + 1;

    ec(sockfd = socket(AF_UNIX, SOCK_STREAM, 0));
    ec(connect(sockfd, (struct sockaddr*) &addr, len));
    return sockfd;
}


void matsock_close(int fd)
{
    ec(close(fd));
}


void matsock_recv(int fd, char* buf, int buflen)
{
    int i;
    for (i = 0; i < buflen; ++i) {
        ec(recv(fd, buf+i, 1, 0));
        if (buf[i] == '\n') {
            buf[i] = 0;
            return;
        }
    }
    buf[buflen-1] = 0;
}


void matsock_send(int fd, char* s)
{
    if (*s)
        ec(send(fd, s, strlen(s), 0));
    ec(send(fd, "\n", 1, 0));
}


void matsock_recvdarray(int fd, double* buf, int len)
{
    int i;
    int n = len * sizeof(double);
    char* p = (char*) buf;
    while (n > 0) {
        int m;
        ec(m = recv(fd, p, n, 0));
        p += m;
        n -= m;
    }
    for (i = 0; i < len; ++i)
        buf[i] = ntohd(buf[i]);
}


void matsock_recviarray(int fd, int* buf, int len)
{
    int i;
    int n = len * sizeof(int32_t);
    int32_t* tmp = mxMalloc(n);
    char* p = (char*) tmp;
    while (n > 0) {
        int m;
        ec(m = recv(fd, p, n, 0));
        p += m;
        n -= m;
    }
    for (i = 0; i < len; ++i)
        buf[i] = ntohl(tmp[i]);
    mxFree(tmp);
}


void matsock_senddarray(int fd, double* buf, int len)
{
    int i;
    double* tmp = mxMalloc(len * sizeof(double));
    for (i = 0; i < len; ++i)
        tmp[i] = htond(buf[i]);
    ec(send(fd, tmp, len * sizeof(double), 0));
    mxFree(tmp);
}


void matsock_sendiarray(int fd, int* buf, int len)
{
    int i;
    int32_t* tmp = mxMalloc(len * sizeof(int32_t));
    for (i = 0; i < len; ++i)
        tmp[i] = htonl(buf[i]);
    ec(send(fd, tmp, len * sizeof(int32_t), 0));
    mxFree(tmp);
}
