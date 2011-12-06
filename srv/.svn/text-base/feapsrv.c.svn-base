/*
 * FEAP socket server
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <arpa/inet.h>


/*@T
 * \section{Synchronization}
 *
 * In order to communicate over a socket, we need some protocol for telling
 * who is writing and who is reading.  Otherwise, it's easy to get into a
 * deadlock, where the client is trying to send a command while the server
 * is itself blocked on a send.  The [[feapsync]] function sends a string
 * that can be used as a synchronization point by the client, so that (for
 * example) the client won't send one command until the previous command has
 * finished.  This isn't a perfect solution, but it is a useful primitive.
 * 
 * Synchronization messages are accompanied by an integer label -- 0 is
 * a sort of don't care label, and is what we use for all the synchronization
 * messages that aren't explicitly requested by the client.
 *
 * The [[feapsync]] routine is called in four places:
 * \begin{enumerate}
 * \item
 *   During file name entry, the server sends a synchronization message
 *   just before waiting on each read.  This is mostly so that I don't
 *   have to recognize what constitutes a prompt for a filename
 *   (the prompts changed between FEAP 7.x and 8.0).
 *
 * \item
 *   Just before requesting input during a [[tinput]] call, the server
 *   sends a synchronization message.  Like the previous class of messages,
 *   these messages are mainly to prevent me from having to understand
 *   what constitutes a prompt.
 *
 * \item
 *   The last message sent by the server before exit is a synchronization
 *   message.  We use this to keep the client from closing the connection
 *   too soon -- in a well-behaved shutdown, the client shouldn't close the
 *   connection until that last message says that the server is ready.
 *
 * \item
 *   The client can explicitly request a labeled synchronization message
 *   via the FEAP user macro [[serv]].
 * \end{enumerate}
 *
 *@c*/
int feapsync_(int* marker)
{
    printf("\nMATFEAP SYNC %d\n", *marker);
    fflush(stdout);
    return 0;
}

/*@T
 * \section{Type conversion}
 *
 * Even on a single machine, we need to convert all binary data transfered
 * to wire format.  This is because the Java input functions assume wire
 * format independent of what architecture we use.  The [[hton[sl]]] and
 * [[ntoh[ls]]] functions convert between host and network long (32-bit)
 * and short (16-bit) integers, but there is no such standard function for
 * double precision floating point data.  This is what [[ntohd]] and
 * [[htond]] are for.
 *
 *@c*/
double ntohd(double x)
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

double htond(double x)
{
    return ntohd(x);
}

/*@T
 * \section{Sending parameter values}
 * 
 * FEAP has a routine [[pconst()]] that reads in parameter values, but it turns
 * out not to be optimal for MATFEAP for two reasons.  First, if the parameter
 * happens to be invalid, FEAP crashes -- not exactly the ideal behavior.
 * Second, [[pconst()]] sends a prompt to the standard output, and that prompt
 * can screw up the message synchronization used by MATFEAP.
 *
 *@c*/
void feapsrv_param(const char* var, double val)
{
    extern int servparam_(int*, int*, double*);
    int i1;
    int i2;

    if (var[0] >= 'A' && var[0] <= 'Z')
       i1 = 1+var[0]-'A';
    else if (var[0] >= 'a' && var[0] <= 'z')
       i1 = 1+var[0]-'a';
    else
       return;  /* Invalid name */

    if (var[1] == '\0')
        i2 = 0;
    else if (var[1] >= 'A' && var[1] <= 'Z')
        i2 = 1+(var[1]-'A');
    else if (var[1] >= 'a' && var[1] <= 'z')
        i2 = 1+(var[1]-'a');
    else if (var[1] >= '0' && var[1] <= '9')
        i2 = 27+(var[1]-'0');
    else
        return;  /* Invalid name */

    servparam_(&i1, &i2, &val);
}


/*@T
 * \section{Sending binary arrays}
 *
 * To send an array to the client, we use the following protocol.
 * \begin{enumerate}
 * \item Server sends: {\tt Send {\it type} {\it count}}, where
 *   {\it type} is {\tt i} (integer) or {\tt d} (double), and
 *   {\it count} is an integer indicating the number of values to
 *   be sent.
 * \item Client sends: {\tt text} or {\tt binary} or {\tt cancel}.
 * \item Server sends: nothing if the client requested {\tt cancel}; a
 *   stream of 32-bit integers or 64-bit doubles in wire format if the
 *   client requested {\tt binary}; or ordinary text representations of
 *   the array data, printed one per line, if the client requested
 *   {\tt text}.
 * \end{enumerate}
 *
 * All this assumes that the array was found -- if not, the server would
 * send {\tt Not found} instead of sending a {\tt Send} line, and the
 * interaction would stop there.
 *
 *@c*/
int fmsendint_(int* data, int* len)
{
    char buf[256];
    char* token;
    int i;

    printf("Send int %d\n", *len);
    fflush(stdout);
    if (fgets(buf, sizeof(buf), stdin) == NULL)
        return 0;

    token = strtok(buf, " \t\r\n");
    if (strcmp(token, "text") == 0) {
        for (i = 0; i < *len; ++i)
            printf("%d\n", data[i]);
    } else if (strcmp(token, "binary") == 0) {
        for (i = 0; i < *len; ++i) {
            int32_t datum = htonl(data[i]);
            fwrite(&datum, sizeof(int32_t), 1, stdout);
        }
    }
    fflush(stdout);

    return 0;
}

int fmsenddbl_(double* data, int* len)
{
    char buf[256];
    char* token;
    int i;

    printf("Send double %d\n", *len);
    fflush(stdout);
    if (fgets(buf, sizeof(buf), stdin) == NULL)
        return 0;

    token = strtok(buf, " \t\r\n");
    if (strcmp(token, "text") == 0) {
        for (i = 0; i < *len; ++i)
            printf("%g\n", data[i]);
    } else if (strcmp(token, "binary") == 0) {
        for (i = 0; i < *len; ++i) {
            double datum = htond(data[i]);
            fwrite(&datum, sizeof(double), 1, stdout);
        }
    }
    fflush(stdout);

    return 0;
}

/*@T
 * \section{Receiving binary arrays}
 *
 * To receive an array to the client, we use a protocol very similar
 * to the one used for sending:
 * \begin{enumerate}
 * \item Server sends: {\tt Recv {\it type} {\it count}}, where
 *   {\it type} is {\tt i} (integer) or {\tt d} (double), and
 *   {\it count} is an integer indicating the number of values to
 *   be sent.
 * \item Client sends: {\tt text} or {\tt binary} or {\tt cancel}.
 * \item Client sends: nothing if the client requested {\tt cancel}; a
 *   stream of 32-bit integers or 64-bit doubles in wire format if the
 *   client requested {\tt binary}; or ordinary text representations of
 *   the array data, printed one per line, if the client requested
 *   {\tt text}.
 * \end{enumerate}
 *
 * All this assumes that the array was found -- if not, the server would
 * send {\tt Not found} instead of sending a {\tt Send} line, and the
 * interaction would stop there.
 *
 * It is much more likely that a receive request will be canceled than
 * that a send request will be canceled.  When the client wants to receive
 * some data, it dynamically allocates as much space as needed to hold
 * the response; but when the client wants to send data, it has to send
 * exactly as much as the FEAP array wants.
 *
 *@c*/
int fmrecvint_(int* data, int* len)
{
    char buf[256];
    char* token;
    int i;

    printf("Recv int %d\n", *len);
    fflush(stdout);
    if (fgets(buf, sizeof(buf), stdin) == NULL)
        return 0;

    token = strtok(buf, " \t\r\n");
    if (strcmp(token, "text") == 0) {
        for (i = 0; i < *len; ++i)
            scanf("%d", &(data[i]));
    } else if (strcmp(token, "binary") == 0) {
        for (i = 0; i < *len; ++i) {
            int32_t datum;
            fread(&datum, sizeof(int32_t), 1, stdin);
            data[i] = ntohl(datum);
        }
    }

    return 0;
}

int fmrecvdbl_(double* data, int* len)
{
    char buf[256];
    char* token;
    int i;

    printf("Recv double %d\n", *len);
    fflush(stdout);
    if (fgets(buf, sizeof(buf), stdin) == NULL)
        return 0;

    token = strtok(buf, " \t\r\n");
    if (strcmp(token, "text") == 0) {
        for (i = 0; i < *len; ++i)
            scanf("%lg", &(data[i]));
    } else if (strcmp(token, "binary") == 0) {
        for (i = 0; i < *len; ++i) {
            double datum;
            fread(&datum, sizeof(double), 1, stdin);
            data[i] = ntohd(datum);
        }
    }

    return 0;
}

/*@T
 * \section{Sending sparse arrays}
 *
 * Sparse arrays are sent from FEAP to MATLAB in coordinate form.  Transfer
 * from MATLAB back to FEAP is currently not supported.  There was already
 * a FORTRAN routine in place to print various FEAP sparse matrices to a
 * file for later retrieval in MATLAB; I adapted that routine for use in
 * MATFEAP by changing all the file I/O routines into calls to [[writeaij]]
 * (below).  Sending an array consists of two steps: 
 * \begin{enumerate}
 * \item 
 *   A call to [[matspew]] to accumulate a count of the number
 *   of nonzero coordinates to be sent during the data transfer.
 *   After making the count, we send a message {\tt nnz {\it count}} to
 *   the client.
 * \item 
 *   A second call to [[matspew]] to send the data.  For the binary version
 *   of the protocol, the data is sent in triplets: [[i, j, Aij]],
 *   where [[i]] and [[j]] are 32-bit integers in wire format and
 *   [[Aij]] is a wire format double.  For text versions of the protocol,
 *   the data is sent with one triple per line.
 * \end{enumerate}
 *
 *@c*/
int writeaij_(int* i, int* j, double* aij, int* count)
{
    /* Cases:
     *  count >=  0 -- accumulate count
     *  count == -1 -- output as text
     *  count == -2 -- output as binary
     */
    if (*count >= 0) {
        ++(*count);
    } else if (*count == -1) {
        printf("%d %d %lg\n", *i, *j, *aij);
    } else if (*count == -2) {
        double coord[3];
        coord[0] = htond(*i);
        coord[1] = htond(*j);
        coord[2] = htond(*aij);
        fwrite(coord, sizeof(double), 3, stdout);
    }
    return 0;
}

void sparse_write(char* types, char* var)
{
    extern int matspew_(char* var, int* cnt);
    int type = 0;
    if (strcmp(types, "text") == 0)
        type = -1;
    else if (strcmp(types, "binary") == 0)
        type = -2;
    if (type && var) {
        int cnt = 0;
        matspew_(var, &cnt);
        printf("nnz %d\n", cnt);
        cnt = type;
        matspew_(var, &cnt);
    }
}

/*@T
 * \section{The [[feapsrv]] dispatcher}
 *
 * The [[feapsrv]] routine is called both at the beginning of the
 * MATFEAP run and whenever the user macro [[serv]] is invoked.
 * This routine provides a common interface for receiving and dispatching
 * most of the commands used by MATFEAP.  In order to keep me honest --
 * and in order to aid debugging -- I have tried to make it possible to
 * use the [[feapsrv]] subcommands as an ordinary user at a terminal
 * interface.  This means, among other things, that there is a help string.
 *
 *@c*/
char* FEAPSRV_HELP = 
    "Commands are:\n"
    "  start           - Start / resume ordinary FEAP interaction\n"
    "  quit            - Terminate this FEAP process\n"
    "  help            - Get this message\n"
    "  cd DIR          - Change to directory DIR\n"
    "  cd              - Print current working directory\n"
    "  param           - Set FEAP parameters\n"
    "  set VAR         - Set FEAP common block variable\n"
    "  get VAR         - Print FEAP common block variable\n"
    "  getm VAR        - Start get of FEAP array\n"
    "  setm VAR        - Start set FEAP array\n"
    "  sparse FMT VAR  - Get FEAP sparse matrix as binary or text\n"
    "  clear_isformed  - Clear with the 'resid formed' flag\n"
    "\n"
    "You can enter server mode from FEAP using the 'serv' macro.\n"
    "See the source code / documentation for more information on the\n"
    "protocols used to exchange arrays and sparse matrices\n";

int feapsrv_()
{
    char buf[256];
    printf("FEAPSRV>\n");
    fflush(stdout);
    while (fgets(buf, sizeof(buf), stdin) != NULL) {
        char* token = strtok(buf, " \t\r\n");
        if (token == NULL) {
            continue;
        } else if (strcmp(token, "start") == 0) {
            return 0;
        } else if (strcmp(token, "quit") == 0) {
            exit(0);
        } else if (strcmp(token, "help") == 0) {
            printf(FEAPSRV_HELP);
        } else if (strcmp(token, "cd") == 0) {
            token = strtok(NULL, " \t\r\n");
            if (token == NULL) 
                printf("PWD: %s\n", getcwd(buf, sizeof(buf)));
            else if (chdir(token) < 0)
                perror("chdir");
        } else if (strcmp(token, "param") == 0) {
            char* name = strtok(NULL, " \t\r\n");
            char* valtok = strtok(NULL, " \t\r\n");
            double val = atof(valtok);
            feapsrv_param(name, val);
        } else if (strcmp(token, "set") == 0) {
            extern int feapget_(char* var, char* mode);
            token = strtok(NULL, " \t\r\n");
            if (token) {
                int n = strlen(token);
                token[n] = ' ';
                feapget_(token, "w");
                token[n] = 0;
            }
        } else if (strcmp(token, "get") == 0) {
            extern int feapget_(char* var, char* mode);
            token = strtok(NULL, " \t\r\n");
            if (token) {
                int n = strlen(token);
                token[n] = ' ';
                feapget_(token, "r");
                token[n] = 0;
            }
        } else if (strcmp(token, "getm") == 0) {
            extern int feapgetm_(char* var, int len);
            token = strtok(NULL, " \t\r\n");
            if (token)
                feapgetm_(token, strlen(token));
        } else if (strcmp(token, "setm") == 0) {
            extern int feapsetm_(char* var, int len);
            token = strtok(NULL, " \t\r\n");
            if (token)
                feapsetm_(token, strlen(token));
        } else if (strcmp(token, "sparse") == 0) {
            char* transfertype = strtok(NULL, " \t\r\n");
            char* varname = strtok(NULL, " \t\r\n");
            if (transfertype && varname)
                sparse_write(transfertype, varname);
        } else if (strcmp(token, "clear_isformed") == 0) {
            extern int feaptformed_();
            feaptformed_();
        } else {
            printf("Unrecognized command: %s\n", token);
        }
        printf("FEAPSRV>\n");
        fflush(stdout);
    }
    return 0;
}
