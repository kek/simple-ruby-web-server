#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define handle_error(msg) \
    do { perror(msg); exit(EXIT_FAILURE); } while (0)

#define ensure(condition, message) \
    if(!(condition)) { puts(message); exit(EXIT_FAILURE); }

int main(char argc, char **argv) {
    int socket_desc, client_sock, read_size, port, address_len;
    char *port_env;
    struct sockaddr_in server, client;
    char client_message[2000];

    port_env = getenv("PORT");
    ensure(port_env != NULL, "PORT must be set");

    port = atoi(port_env);
    ensure(port > 0, "PORT must be a number over 0");

    socket_desc = socket(AF_INET, SOCK_STREAM, 0);
    if(socket_desc == -1)
        handle_error("Could not create socket");

    server.sin_family = AF_INET;
    server.sin_addr.s_addr = INADDR_ANY;
    server.sin_port = htons(port);

    if(bind(socket_desc, (struct sockaddr *) &server, sizeof(server)) == -1)
        handle_error("bind");

    if(listen(socket_desc, 3) == -1)
        handle_error("listen");

    address_len = sizeof(struct sockaddr_in);
    client_sock = accept(socket_desc, (struct sockaddr *) &client,
            (socklen_t*) &address_len);

    if(client_sock < 0) handle_error("accept");

    while((read_size = recv(client_sock, client_message, 2000, 0)) > 0) {
        write(client_sock, client_message, strlen(client_message));
    }

    if(read_size == 0) {
        puts("Client disconnected");
        fflush(stdout);
    } else if(read_size == -1) {
        handle_error("recv");
    }

    return 0;
}
