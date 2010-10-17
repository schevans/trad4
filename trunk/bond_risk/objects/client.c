/*
** client.c -- a stream socket client demo
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <netdb.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <sys/socket.h>

#include <iostream>

using namespace std;

#include "trad4.h"
#include "calendar.h"
#include "ir_curve.h"
#include "bond.h"
#include "outright_trade.h"
#include "repo_trade.h"
#include "outright_book.h"
#include "repo_book.h"

#include <arpa/inet.h>

#define PORT "3490" // the port client will be connecting to 

#define MAXDATASIZE 100 // max number of bytes we can get at once 

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }

    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

int main(int argc, char *argv[])
{
    int sockfd, numbytes;  
    char buf[MAXDATASIZE];
    struct addrinfo hints, *servinfo, *p;
    int rv;
    char s[INET6_ADDRSTRLEN];

    if (argc != 2) {
        fprintf(stderr,"usage: client id\n");
        exit(1);
    }

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;

    if ((rv = getaddrinfo("localhost", PORT, &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return 1;
    }

    // loop through all the results and connect to the first we can
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                p->ai_protocol)) == -1) {
            perror("client: socket");
            continue;
        }

        if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
            close(sockfd);
            perror("client: connect");
            continue;
        }

        break;
    }

    if (p == NULL) {
        fprintf(stderr, "client: failed to connect\n");
        return 2;
    }

    inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr),
            s, sizeof s);
    printf("client: connecting to %s\n", s);

    freeaddrinfo(servinfo); // all done with this structure

    int id=atoi(argv[1]);

    // Create and send header_request
    t4::request header_request;
    header_request.request_type = t4::GET_HEADER;
    header_request.id = id; 

    if (send(sockfd, &header_request, sizeof(t4::request), 0) == -1)
        perror("send");
   
    // Receive header
    object_header header;

    if ((numbytes = recv(sockfd, &header, sizeof(object_header), 0)) == -1) {
        perror("recv");
        exit(1);
    }

    if ( header.id != 0 )
    {
        // Create and send body request
        t4::request body_request;
        body_request.request_type = t4::GET_BODY;
        body_request.id = id;

        if (send(sockfd, &header_request, sizeof(t4::request), 0) == -1)
            perror("send");

        switch ( header.type ) {

            case 0:
                std::cerr << "Request for object id " << header_request.id << " failed - object not found." << std::endl;
                break;

            case 2:

                t4::ir_curve ir_curve_in;

                if ((numbytes = recv(sockfd, &ir_curve_in, sizeof(t4::ir_curve), 0)) == -1) {
                    perror("recv");
                    exit(1);
                }

                for ( int i=0 ; i < NUM_INPUT_RATES ; i++ )
                {
                    cout << i << ": " << ir_curve_in.input_rates[i].value << endl; 
                }

                break;

            case 3:

                t4::bond bond_in;

                if ((numbytes = recv(sockfd, &bond_in, sizeof(t4::bond), 0)) == -1) {
                    perror("recv");
                    exit(1);
                }
                cout << "bond_in.start_date: " << bond_in.start_date << endl; 
                cout << "bond_in.maturity_date: " << bond_in.maturity_date << endl; 
                break;

            case 4:

                t4::outright_trade outright_trade_in;

                if ((numbytes = recv(sockfd, &outright_trade_in, sizeof(t4::outright_trade), 0)) == -1) {
                    perror("recv");
                    exit(1);
                }
                cout << "outright_trade_in.trade_price: " << outright_trade_in.trade_price << endl;
                cout << "outright_trade_in.quantity: " << outright_trade_in.quantity << endl;
                break;

            default:
               cout << "Unhandled type " << header.type << endl; 

        }
    }
    else
    {
        std::cerr << "Request for object id " << header_request.id << " failed - object not found." << std::endl;
    }
    
    close(sockfd);

    return 0;
}

