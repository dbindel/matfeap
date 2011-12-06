#ifndef MATSOCK_H
#define MATSOCK_H

int matsock_new_tcp(const char* hostname, int port);
int matsock_new_unix(const char* sockname);
void matsock_close(int fd);
void matsock_recv(int fd, char* buf, int buflen);
void matsock_send(int fd, char* s);
void matsock_recvdarray(int fd, double* buf, int len);
void matsock_recviarray(int fd, int*    buf, int len);
void matsock_senddarray(int fd, double* buf, int len);
void matsock_sendiarray(int fd, int*    buf, int len);

#endif /* MATSOCK_H */
