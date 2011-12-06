
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <time.h>

#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <sys/socket.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#define MYPORT 3490
#define PORT_ENV_VAR "MATFEAP_PORT"
#define SOCKNAME_ENV_VAR "MATFEAP_SOCKNAME"
#define BACKLOG 5


/* Error check macro */
#define ec(cmd) \
    do {\
        char ec_error_string_buf[128]; \
        sprintf(ec_error_string_buf, "%s (%d)", __FILE__, __LINE__); \
        if ((cmd) < 0) { \
            perror(ec_error_string_buf); \
            exit(-1); \
        } \
    } \
    while (0)

/*@T
 * \section{Reaping child processes}
 *
 * In UNIX, child processes are not released to the system until after the
 * parent process checks the child process exit status using [[wait]] or
 * [[waitpid]].  We install a handler on SIGCHLD events (change of child
 * status) that checks the exit status of any child processes that are 
 * finished.
 * 
 * This is a standard piece of most UNIX daemons.
 *
 *@c*/
static void sigchld_handler(int s)
{
    while (waitpid(-1, NULL, WNOHANG) > 0);
}

static void install_reaper()
{
    struct sigaction sa;
    sa.sa_handler = sigchld_handler;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = SA_RESTART;
    ec(sigaction(SIGCHLD, &sa, NULL));
}

/*@T
 * \section{Receiving TCP socket connections}
 *
 * On the server side, there are two phases to setting up a socket connection.
 * First, we need to set up a socket -- create it, give it an address with
 * [[bind]], and use [[listen]] to tell the system that we can receive
 * connections on it.  By default, the server listens on [[MYPORT]] (3490),
 * but this value can be changed by setting the [[MATFEAP_PORT]] environment
 * variable.
 *
 *@c*/
static int tcp_socket_setup(int port)
{
    int sockfd;                           /* socket file descriptor */
    struct sockaddr_in my_addr;           /* my address information */
    int yes=1;

    memset(&my_addr, 0, sizeof(my_addr));
    my_addr.sin_family = AF_INET;
    my_addr.sin_port = htons(port);
    my_addr.sin_addr.s_addr = INADDR_ANY;

    ec(sockfd = socket(AF_INET, SOCK_STREAM, 0));
    ec(setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int)));
    ec(bind(sockfd, (struct sockaddr*) &my_addr, sizeof(my_addr)));
    ec(listen(sockfd, BACKLOG));

    printf("Server listening on port %d\n", port);
    return sockfd;
}

static int tcp_handle_connection(int sockfd)
{
    struct sockaddr_in their_addr;
    socklen_t sin_size = sizeof(struct sockaddr_in);
    while (1) {
        int new_fd = accept(sockfd, (struct sockaddr*) &their_addr, &sin_size);
        if (new_fd < 0)
            perror("accept");
        else {
            time_t c = time(NULL);
            printf("Connection from %s -- %s",
                   inet_ntoa(their_addr.sin_addr), ctime(&c));
            return new_fd;
        }
    }
}

/*@T
 * \section{Receiving local socket connections}
 *
 * In addition to TCP socket connections, we allow the server to use
 * UNIX domain socket connections.  UNIX domain sockets are used in various
 * other system servers as well, including X11.  The primary advantage of
 * UNIX-domain sockets over TCP sockets is performance: if you're
 * going to run both the client and the server on the same machine and
 * you use a UNIX-domain socket, then the operating system can handle
 * context switches a little more intelligently.  The disadvantage of
 * using UNIX domain sockets is that Java doesn't know about them at
 * this time -- you have to use the MEX-based socket infrastructure to
 * connect to the UNIX domain server.
 *
 * UNIX domain sockets differ from TCP sockets primarily in the setup
 * phase -- afterward, everything works the same.  The location of a
 * UNIX domain socket is specified as a filesystem location rather than
 * a port number.  We use the existence of a port name to tell MATFEAP
 * to listen on a UNIX domain socket.
 *
 *@c*/
static int local_socket_setup(const char* sockname)
{
    int sockfd;                           /* socket file descriptor */
    struct sockaddr_un my_addr;           /* my address information */
    int len;

    /* Remove any previous socket */
    unlink(sockname);

    memset(&my_addr, 0, sizeof(my_addr));
    my_addr.sun_family = AF_UNIX;
    strcpy(my_addr.sun_path, sockname);
    len = sizeof(my_addr.sun_family) + strlen(my_addr.sun_path) + 1;

    ec(sockfd = socket(AF_UNIX, SOCK_STREAM, 0));
    ec(bind(sockfd, (struct sockaddr*) &my_addr, len));
    ec(listen(sockfd, BACKLOG));

    printf("Server listening on local socket %s\n", sockname);
    return sockfd;
}

static int local_handle_connection(int sockfd)
{
    struct sockaddr_un their_addr;
    socklen_t sin_size = sizeof(struct sockaddr_un);
    while (1) {
        int new_fd = accept(sockfd, (struct sockaddr*) &their_addr, &sin_size);
        if (new_fd < 0)
            perror("accept");
        else {
            time_t c = time(NULL);
            printf("Connection -- %s", ctime(&c));
            return new_fd;
        }
    }
}

/*@T
 * \section{Deciding on a socket connections}
 *
 * We decide whether to use TCP or UNIX domain sockets based on
 * the setting of the environment variables.  If
 * [[MATFEAP_SOCKNAME]] is set, we use that as the address for
 * a local UNIX-domain socket.  Otherwise, if [[MATFEAP_PORT]] is
 * set, we use that as the port number for a TCP-based socket.
 * If no relevant environment variable is set, then we default to
 * a TCP-based server listening on port 3490.
 *
 *@c*/
static int feapsock_local_socket;

static int socket_setup()
{
    int port = MYPORT;
    char* port_env = getenv(PORT_ENV_VAR);
    char* sockname = getenv(SOCKNAME_ENV_VAR);
    if (port_env)
        port = atoi(port_env);

    feapsock_local_socket = (sockname != 0);
    if (feapsock_local_socket)
        return local_socket_setup(sockname);
    else
        return tcp_socket_setup(port);
}

static int handle_connection(int sockfd)
{
    if (feapsock_local_socket)
        return local_handle_connection(sockfd);
    else
        return tcp_handle_connection(sockfd);
}

/*@T
 * \section{Redirecting I/O streams}
 *
 * UNIX treats socket file descriptors like any other file
 * descriptors.  That means the socket input and output streams can be
 * connected to [[stdin]] (fd 0) and [[stdout]] (fd 1) using the
 * [[dup]] or [[dup2]] system calls.  I leave [[stderr]] alone
 * so that the FEAP server can send debugging information to the terminal
 * without breaking the protocol used to communicate between the server and
 * the client.
 *
 *@c*/
static void send_std_to_socket(int new_fd)
{
    dup2(new_fd, 0);
    dup2(new_fd, 1);
    /*dup2(new_fd, 2);*/
    close(new_fd);
}

/*@T
 * \section{The main daemon}
 *
 * The main loop is a Fortran-callable routine that accepts incoming
 * socket connections from clients and assigns to each a simulation
 * process.  The call to [[feapserver]] in the original process
 * never exits.  In child processes created to handle incoming
 * connections, [[feapserver]] returns control to the calling routine,
 * allowing FEAP to continue running as it usually would.
 *
 *@c*/
int feapserver_()
{
    int sockfd = socket_setup();
    install_reaper();

    while (1) {
        int new_fd = handle_connection(sockfd);
        if (!fork()) {  /* This is the child process */
            close(sockfd);
            send_std_to_socket(new_fd);
            return 0;
        }
        close(new_fd);  /* Parent doesn't need this */
    }

    exit(0);
}

