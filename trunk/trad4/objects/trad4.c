// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//


#include <arpa/inet.h>
#include <cstdio>
#include <dlfcn.h>
#include <errno.h>
#include <iomanip>
#include <iostream>
#include <netdb.h>
#include <netinet/in.h>
#include <pthread.h>
#include <signal.h>
#include <sqlite3.h>
#include <sstream>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

// socket stuff
#define PORT "3490"  // the port users will be connecting to
#define BACKLOG 10     // how many pending connections queue will hold

#include "trad4.h"

using namespace std;

obj_loc_t obj_loc;
tier_manager_t tier_manager;
int thread_contoller[MAX_THREADS+1];
object_type_struct_t* object_type_struct[MAX_TYPES+1];
sqlite3* db;
char *zErrMsg = 0;  // ??

int num_tiers(MAX_TIERS);   // Will be dynamic.
int num_threads(MAX_THREADS);   // Will be dynamic.
int current_thread(1);
int num_threads_fired(0);
bool need_reload(false);
char* timing_debug = 0;
char* batch_mode = 0;
void set_timestamp( obj_loc_t obj_loc, int id );

bool fire_object( int id );
void* thread_loop( void* thread_id );
void start_threads();
void get_timestamp( double& out_time );
int run_tier( int tier );
void reload_handler( int sig_num );
void load_objects( int initial_load );
void load_types( int initial_load );
void print_concrete_graph();
void *get_in_addr(struct sockaddr *sa);
void* tcp_sever_loop( void* thread_id );

void run_trad4( int print_graph ) 
{
    signal(SIGUSR1, reload_handler);

    if ( sqlite3_open(getenv("APP_DB"), &db) != SQLITE_OK )
    {
        cout << "Unable to open " << getenv("APP_DB") << endl;
        exit(1);
    }

    timing_debug = getenv("TIMING_DEBUG");

    batch_mode = getenv("BATCH_MODE");

    for ( int i = 0 ; i < MAX_OBJECTS+1 ; i++ )
    {
        obj_loc[i] = 0;
    }

    for ( int i = 0 ; i < MAX_TYPES+1 ; i++ )
    {
        object_type_struct[i] = 0;
    }

    for ( int i=1 ; i < MAX_TIERS+1 ; i++ )
    {
        tier_manager[i][0]=1;
    }

    // Null object
    obj_loc[0] = (unsigned char*)(new object_header);

    object_last_published(0) = 0;
    object_status(0) = FAILED;
    object_type(0) = 0;
    object_tier(0) = 0;
//    object_name(0) = "Null object";
    object_log_level(0) = 0;
    object_implements(0) = 0;
    object_init(0) = 0;

    load_types( 1 );

    load_objects( 1 );

    for ( int i = 1 ; i < MAX_OBJECTS ; i++ )
    {
        if ( obj_loc[i] )
        {
            tier_manager[((object_header*)obj_loc[i])->tier][tier_manager[((object_header*)obj_loc[i])->tier][0]] = i;
            tier_manager[((object_header*)obj_loc[i])->tier][0]++;
        }
    }

    cout << endl;

    for ( int tier=1 ; tier <= num_tiers ; tier++ )
    {
        if ( tier_manager[tier][0] - 1 > 0 )
        {
            std::cout << "Num objects on T" << tier << ": " << tier_manager[tier][0] - 1 << std::endl; 
        }
    }

    cout << endl;

    if ( print_graph )
    {
        cout << "Printing concrete graph and exiting as app run with the -d flag." << endl; 
        print_concrete_graph();
        exit(0);
    }

    char* num_threads_env = getenv("NUM_THREADS");

    if ( num_threads_env ) 
    {
        num_threads = atoi(num_threads_env);

        if ( num_threads < 0 or num_threads > MAX_THREADS )
        {
            cout << "Warning: NUM_THREADS set to " << num_threads << ". Assuming 1 thread." << endl;
            num_threads = 1;
        }
    }
    else
    {
        cout << "Warning: NUM_THREADS unset. Assuming 1 thread." << endl;
        num_threads = 1;
    }

    start_threads();

    cout << endl;

    sleep(1);

    double start_time;
    double end_time;
    double tier_start_time; 
    double tier_end_time;
    int num_objects_run;
    int num_object_run_this_tier;

    while (1)
    {
        get_timestamp( start_time );
        get_timestamp( tier_start_time );

        num_objects_run = 0;

        for ( int tier=1 ; tier < num_tiers+1 ; tier++ )
        {
            if ( tier_manager[tier][0] <= 1 )
            {
                continue;
            }

            get_timestamp( tier_start_time );

            num_object_run_this_tier = run_tier( tier );

            get_timestamp( tier_end_time );

            num_objects_run = num_objects_run + num_object_run_this_tier;

            if ( timing_debug && num_object_run_this_tier ) 
                cout << setprecision(6) << "Tier " << tier << " ran " << num_object_run_this_tier << " objects in " << tier_end_time - tier_start_time << " seconds." << endl;

        }

        get_timestamp( end_time );

        if ( timing_debug && num_object_run_this_tier ) 
            cout << endl << "All tiers ran " << num_objects_run << " objects in " << end_time-start_time << " seconds." << endl;

        if ( batch_mode )
        {
            cout << endl << "Exiting after first run as BATCH_MODE is set." << endl;
            exit(0);
        }

        usleep(10000);

        if ( need_reload )
        {
            need_reload = false;
    
            load_types( 0 );
    
            load_objects( 0 );
        }
    }
}

void get_timestamp( double& out_time )
{
    timeval tim;
    gettimeofday(&tim, NULL);
    out_time = tim.tv_sec + ( tim.tv_usec / 1000000.0 );
}

int run_tier( int tier ) {

    int num_times_waited_this_tier = 0;

    int num_objects_fired = 0;

    if ( tier_manager[1][0] == 1  )
    {
        cerr << "Error: No objects found on tier 1. Exiting." << endl;
        exit(1);
    }

    for ( int i=1 ; i < tier_manager[tier][0] ; i++ )
    {

        //std::cout << "Checking tier " << tier << ". i=" << i << ", num objs this tier: " << tier_manager[tier][0] - 1 << std::endl; 

        if ( obj_loc[tier_manager[tier][i]] )
        {
            //cout << "Calling need_refresh_fpointer for " << tier_manager[tier][i] << endl;

            if ( (*object_type_struct[((object_header*)obj_loc[tier_manager[tier][i]])->type]->need_refresh)(obj_loc, tier_manager[tier][i] ) ) 
            {

                if ( num_objects_fired == 0 ) 
                {
                    if ( timing_debug ) 
                        cout << endl << "Tier " << tier << " running." << endl;
                }

                while ( ! fire_object( tier_manager[tier][i] ) )
                {
                    //cout << "Fire object failed due to lack of spare threads. Sleeping master thread." << endl;
                    num_times_waited_this_tier++;
                    usleep(5);
                }

                num_objects_fired++;
            }
        }
    }


    // Wait for all the threads to finish with this tier.

    bool thread_still_runnning(true);

    while ( thread_still_runnning )
    {
        thread_still_runnning = false;

        for ( int i=1 ; i <= num_threads ; i++ )
        {
            if ( thread_contoller[i] != 0 )
            {
                thread_still_runnning = true;
                break;
            }
        }

        if ( thread_still_runnning )
        {
            usleep(50);
        }
    }

    if ( num_objects_fired > 0 )
    {
        //cout << "Waited " << num_times_waited_this_tier << " times this tier." << endl;
    }

    return num_objects_fired;
}

bool fire_object( int id )
{
    //std::cout << "fire_object " << id << std::endl;

    bool fired(false);

    int num_threads_checked=0;

    if ( num_threads > 0 ) 
    {

        while ( ! fired && num_threads_checked < num_threads )
        {
            //cout << "current_thread: " << current_thread << std::endl;

            if ( thread_contoller[current_thread] == 0 )
            {
                thread_contoller[current_thread] = id;
                fired = true;
            }

            current_thread++;

            if ( current_thread > num_threads )
                current_thread=1;

            num_threads_checked++;
        }
    }
    else {

        // Single-threaded mode.

        (*object_type_struct[((object_header*)obj_loc[id])->type]->calculate)(obj_loc, id);

        set_timestamp( obj_loc, id );

        fired = 1;
    }

    return fired;
}

void set_timestamp( obj_loc_t obj_loc, int id )
{
    //for ( int i=0 ; i < 1000000000 ; i++ );   // Simulate long calculations

    timeval tim;
    gettimeofday( &tim, NULL );

    double timestamp_double = tim.tv_sec + (tim.tv_usec / 1000000.0);
    long long timestamp = (long long)(timestamp_double * 1000000 );

    //std::cout << "setting timestamp(" << id << "): " << timestamp << std::endl;

    *(long long*)obj_loc[id] = timestamp;
}

void* thread_loop( void* thread_id ) 
{
    bool thread_fired(false);

    while (1) {

        //cout << "thread_contoller[(long long)thread_id] = " << thread_contoller[(long long)thread_id] << endl;

        if ( thread_contoller[(long long)thread_id] != 0 )
        {

            //cout << "Thread #" << (long long)thread_id << " working on obj id: " << thread_contoller[(long long)thread_id] << endl;

            (*object_type_struct[((object_header*)obj_loc[thread_contoller[(long long)thread_id]])->type]->calculate)(obj_loc, thread_contoller[(long long)thread_id] );

            set_timestamp( obj_loc, thread_contoller[(long long)thread_id] );

            //cout << "Thread #" << (long long)thread_id << " done." << endl;
            thread_fired=true;

            thread_contoller[(long long)thread_id] = 0;

            usleep(50);
        }
        else
        {
            usleep(500);
        }
    }

    return obj_loc[0];
}

void start_threads()
{
    for ( int i=1 ; i <= num_threads ; i++ )
    {
        pthread_t t1;

        if ( pthread_create(&t1, NULL, thread_loop, (void *)i) != 0 ) {
            cout << "pthread_create() error" << endl;
            abort();
        }
    }

    if ( num_threads == 0 ) 
    {
        cout << "Running in single-threaded mode." << endl;
    }
    else if ( num_threads == 1 ) 
    {
        cout << "Started " << num_threads << " thread." << endl;
    }
    else
    {
        cout << "Started " << num_threads << " threads." << endl;
    }

    // Start the tcp server thread
    pthread_t t1;

    if ( pthread_create(&t1, NULL, tcp_sever_loop, NULL) != 0 ) {
        cout << "pthread_create() error" << endl;
        abort();
    }

}

void* tcp_sever_loop( void* unused )
{
    int sockfd, new_fd;  // listen on sock_fd, new connection on new_fd
    struct addrinfo hints, *servinfo, *p;
    struct sockaddr_storage their_addr; // connector's address information
    socklen_t sin_size;
    int yes=1;
    char s[INET6_ADDRSTRLEN];
    int rv;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_PASSIVE; // use my IP

    if ((rv = getaddrinfo(NULL, PORT, &hints, &servinfo)) != 0) {
        fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
        return (void*)1;
    }

    // loop through all the results and bind to the first we can
    for(p = servinfo; p != NULL; p = p->ai_next) {
        if ((sockfd = socket(p->ai_family, p->ai_socktype,
                p->ai_protocol)) == -1) {
            perror("server: socket");
            continue;
        }

        if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
                sizeof(int)) == -1) {
            perror("setsockopt");
            exit(1);
        }

        if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
            close(sockfd);
            perror("server: bind");
            continue;
        }

        break;
    }

    if (p == NULL)  {
        fprintf(stderr, "server: failed to bind\n");
        return (void*)2;
    }

    freeaddrinfo(servinfo); // all done with this structure

    if (listen(sockfd, BACKLOG) == -1) {
        perror("listen");
        exit(1);
    }

    printf("Started server. Waiting for connections...\n");

    while(1) {  // main accept() loop
        sin_size = sizeof their_addr;

        new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &sin_size);
        if (new_fd == -1) {
            perror("accept");
            continue;
        }
        inet_ntop(their_addr.ss_family,
            get_in_addr((struct sockaddr *)&their_addr),
            s, sizeof s);
        printf("Server: got connection from %s\n", s);

        int numbytes;

        t4::request header_request;        

        if ((numbytes = recv(new_fd, &header_request, sizeof(t4::request), 0)) == -1) {
            perror("recv");
            exit(1);
        }

        if ( header_request.id != 0 && obj_loc[header_request.id] )
        {

            if (send(new_fd, obj_loc[header_request.id], sizeof(object_header), 0) == -1)
                perror("send");

            t4::request body_request;        

            if ((numbytes = recv(new_fd, &body_request, sizeof(t4::request), 0)) == -1) {
                perror("recv");
                exit(1);
            }

            size_t object_size = (*object_type_struct[((object_header*)obj_loc[header_request.id])->type]->get_object_size)();

            if (send(new_fd, obj_loc[header_request.id], object_size, 0) == -1)
            perror("send");
        }
        else 
        {
            std::cerr << "Request for object id " << header_request.id << " failed - object not found." << std::endl;
            object_header null_header;
            null_header.id=0;

            if (send(new_fd, &null_header, sizeof(object_header), 0) == -1)
                perror("send");
        }

        close(new_fd);
    }

    return (void*)0;
}

// get sockaddr, IPv4 or IPv6:
void *get_in_addr(struct sockaddr *sa)
{
    if (sa->sa_family == AF_INET) {
        return &(((struct sockaddr_in*)sa)->sin_addr);
    }

    return &(((struct sockaddr_in6*)sa)->sin6_addr);
}

void reload_handler( int sig_num )
{
    signal(SIGUSR1, reload_handler);

    cout << "reload_handler" << endl;
    need_reload = true;
}

static int load_types_callback(void *NotUsed, int argc, char **row, char **azColName)
{
    char *error;

    int type_id = atoi(row[0]);
    char* name = row[1];

    if ( type_id > MAX_TYPES )
    {
        cerr << "Error: Type '" << name << "' has type id " << type_id << " which is greater than MAX_TYPES (" << MAX_TYPES << "). Please increase MAX_TYPES in trad4.h and recompile." << endl;
        exit(1);
    }

    if ( object_type_struct[type_id] == 0 )
    {
        cout << "Creating new type " << name << ", type_id: " << type_id << endl;

        object_type_struct[type_id] = new object_type_struct_t;
    }
    else 
    {
        cout << "Reloading type " << name << ", type_id: " << type_id << endl;

        dlclose(object_type_struct[type_id]->lib_handle);
        object_type_struct[type_id]->need_refresh = 0;
        object_type_struct[type_id]->calculate = 0;
        object_type_struct[type_id]->load_objects = 0;
        object_type_struct[type_id]->validate = 0;
        object_type_struct[type_id]->print_concrete_graph = 0;
        object_type_struct[type_id]->get_object_size = 0;
    }

    ostringstream lib_name;
    lib_name << getenv("APP_ROOT") << "/lib/libt4" << name << ".so";

    (object_type_struct[type_id])->lib_handle = dlopen (lib_name.str().c_str(), RTLD_LAZY);
    if (!object_type_struct[type_id]->lib_handle) {
        fputs (dlerror(), stderr);
        exit(1);
    }

    object_type_struct[type_id]->need_refresh = (need_refresh_fpointer)dlsym(object_type_struct[type_id]->lib_handle, "need_refresh");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    object_type_struct[type_id]->calculate = (calculate_fpointer)dlsym(object_type_struct[type_id]->lib_handle, "calculate");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    object_type_struct[type_id]->load_objects = (load_objects_fpointer)dlsym(object_type_struct[type_id]->lib_handle, "load_objects");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    object_type_struct[type_id]->validate = (validate_fpointer)dlsym(object_type_struct[type_id]->lib_handle, "validate");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    object_type_struct[type_id]->print_concrete_graph = (print_concrete_graph_fpointer)dlsym(object_type_struct[type_id]->lib_handle, "print_concrete_graph");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    object_type_struct[type_id]->get_object_size = (get_object_size_fpointer)dlsym(object_type_struct[type_id]->lib_handle, "get_object_size");
    if ((error = dlerror()) != NULL)  {
        fputs(error, stderr);
        exit(1);
    }

    return 0;
}

void load_types( int initial_load )
{

    std::ostringstream dbstream;

    if ( initial_load ) 
        dbstream << "select type_id, name from object_types";
    else
        dbstream << "select type_id, name from object_types where need_reload=1";
        
    if( sqlite3_exec(db, dbstream.str().c_str(), load_types_callback, 0, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s. File %s, line %d.\n", zErrMsg, __FILE__, __LINE__);
        sqlite3_free(zErrMsg);
    }
}

static int load_objects_callback(void* initial_load_v, int argc, char **row, char **azColName)
{
    int initial_load = *((int*)initial_load_v);

    (*object_type_struct[atoi(row[0])]->load_objects)( obj_loc, initial_load );

    return 0;
}

void load_objects( int initial_load )
{
    if ( initial_load ) 
        cout << "Loading objects..." << endl;
    else
        cout << "Reloading objects..." << endl;

    std::ostringstream dbstream;
    dbstream << "select type_id from object_types";

    if ( initial_load != 1 )
        dbstream << " where need_reload=1";

    if( sqlite3_exec(db, dbstream.str().c_str(), load_objects_callback, (void*)&initial_load, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s. File %s, line %d.\n", zErrMsg, __FILE__, __LINE__);
        sqlite3_free(zErrMsg);
    }

    cout << "Validating objects..." << endl;

    for ( int i = 1 ; i < MAX_OBJECTS ; i++ )
    {
        if ( obj_loc[i] && object_last_published(i) == 0 )
        {
            if ( ! ((object_type_struct[((object_header*)obj_loc[i])->type])->validate)( obj_loc, i ) )
            {
                if ( object_init(i) )
                {
                    object_status( i ) = STALE;
                    cerr << "Error: Object " << i << " is STALE as it failed validation on reload." << endl;
                }
                else
                {
                    object_status( i ) = FAILED;
                    cerr << "Error: Object " << i << " is FAILED as it hasn't initilised and it failed validation." << endl;
                }

                set_timestamp( obj_loc, i );

            }
        }
    }

    dbstream.str("");
    dbstream << "update object set need_reload=0";

    if( sqlite3_exec(db, dbstream.str().c_str(), 0, 0, &zErrMsg) != SQLITE_OK ){
        fprintf(stderr, "SQL error: %s. File %s, line %d.\n", zErrMsg, __FILE__, __LINE__);
        sqlite3_free(zErrMsg);
    }
}

void print_concrete_graph()
{
    ofstream outfile;
    outfile.open ("concrete.dot");

    outfile << "digraph concrete {" << endl;

    outfile << "" << endl;
    outfile << "    rankdir=TD;" << endl;
    outfile << "    {" << endl;
    outfile << "        node [shape=plaintext, fontsize=16 ]" << endl;
    outfile << "    " << endl;

    int max_tier(0);

    for ( int tier=1 ; tier <= MAX_TIERS ; tier++ )
    {
        if ( tier_manager[tier][0] - 1 > 0 )
        {
            if ( tier > max_tier ) 
            {
                max_tier = tier;
            }
        }
    }

    outfile << "        T" << max_tier;

    for ( int tier=max_tier-1 ; tier > 0 ; tier-- )
    {
        if ( tier_manager[tier][0] - 1 > 0 )
        {
            outfile << " -> T" << tier;
        }
    }

    outfile << " [ dir=back ]" << endl;
    outfile << "    " << endl;
    outfile << "    }" << endl;
    outfile << "" << endl;

    for ( int tier=1; tier < MAX_TIERS ; tier++ )
    {
        if ( tier_manager[tier][0] - 1 > 0 )
        {
            for ( int i=1 ; i <= tier_manager[tier][0] - 1 ; i++ )
            {
                outfile << "    t4_" << object_type(tier_manager[tier][i]) << "_" << tier_manager[tier][i] << " [label=\"" << object_name(tier_manager[tier][i]) << "\" shape=ellipse]" << endl;
            }
        }
    }

    outfile << "" << endl;

    for ( int tier=1; tier < MAX_TIERS ; tier++ )
    {
        for ( int i=1 ; i < tier_manager[tier][0] ; i++ )
        {
            if ( obj_loc[tier_manager[tier][i]] )
            {
                 (*object_type_struct[((object_header*)obj_loc[tier_manager[tier][i]])->type]->print_concrete_graph)(obj_loc, tier_manager[tier][i], outfile );
            }
        }
    }

    outfile << "" << endl;

    for ( int tier=1; tier < MAX_TIERS ; tier++ )
    {
        if ( tier_manager[tier][0] - 1 > 0 )
        {
            outfile << "    {rank=same;";

            for ( int i=1 ; i <= tier_manager[tier][0] - 1 ; i++ )
            {
                outfile << " t4_" << object_type(tier_manager[tier][i]) << "_" << tier_manager[tier][i];
            }
    
            outfile << " }" << endl;
        }
    }

    outfile << endl;
    outfile << "}" << endl;
    outfile << endl;

    outfile.close();

}
