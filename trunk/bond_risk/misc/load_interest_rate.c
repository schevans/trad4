// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk

#include <sys/shm.h>
#include <fstream>
#include <iostream>
#include <sstream>
#include <sys/time.h>
#include "mysql/mysql.h"

#include "trad4.h"
#include "interest_rate_feed.h"

using namespace std;

int main(int argc,char *argv[]) {

    if ( argc != 2 ) {
        cout << "usege: load_interest_rate <id>" << endl;
        exit(0);
    }

    int id=atoi(argv[1]);

    char* interes_rate_file_name = "/tmp/interest_rate_feed.txt";

    if ( interes_rate_file_name == NULL )
    {
        cout << "OBJ_LOC_FILE not set. Exiting" << endl;
        exit(1);
    }

    fstream interest_rate_file(interes_rate_file_name, ios::in);

    if ( ! interest_rate_file.is_open() )
    {
        cout << "interest_rate not running. Exiting." << endl;
        exit (1);
    }

    char buffer[32];
    char* tok;
    int current_id(0);
    int shmid(0);

    bool found(0);

    while ( interest_rate_file >> buffer )
    {
        tok = strtok( buffer, "," );
        current_id = atoi(tok);
        tok = strtok( NULL, "," );
        shmid = atoi(tok);

        if ( current_id == id ) 
        {
            found = true;
            break;
        } 
    }

    interest_rate_file.close();

    if ( ! found ) 
    {
        cout << "IR " << id << " not found in file " << interes_rate_file_name << ". Exiting" << endl;
        exit(0);
    }

    void* shm;

    if ((shm = shmat(shmid, NULL, 0)) == (char *) -1) {
        perror("shmat");
        exit(1);
    }

    interest_rate_feed_sub* interest_rate = (interest_rate_feed_sub*)shm;

    MYSQL mysql;
    MYSQL_RES *result;
    MYSQL_ROW row;

    mysql_init(&mysql);

    if (!mysql_real_connect(&mysql,"localhost", "root", NULL,"trad4",0,NULL,0)) {
        cout << __LINE__ << " "  << mysql_error(&mysql) << endl;
    }
 
    ostringstream dbstream;
    dbstream << "select asof, rate from interest_rate_feed_data where id=" << id;

    if(mysql_query(&mysql, dbstream.str().c_str()) != 0) {
        cout << __LINE__ << ": " << mysql_error(&mysql) << endl;
    }

    result = mysql_use_result(&mysql);

    int counter(0);

    while (( row = mysql_fetch_row(result) )) {

        interest_rate->asof[counter]  = atoi(row[0]);
        interest_rate->rate[counter]  = atof(row[1]);

        counter++;
    }

    timeval time;
    gettimeofday( &time, NULL );
    int sec = time.tv_sec;
    int mil = time.tv_usec;

    int timestamp = (( sec - 1203000000 ) * 1000 ) + ( mil / 1000 );

    interest_rate->last_published = timestamp;

    return 0;
}
