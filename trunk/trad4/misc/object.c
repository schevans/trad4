
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE


#include <iostream>
#include <sstream>
#include <unistd.h>    
#include <sys/types.h> 
#include <signal.h>    

#include "Object.h"
#include "ObjectFactory.h"

using namespace std;

Object* object;

void sighup_handler(int sig_num)
{
    object->Stop();
    exit(0);
}

void sigusr1_handler(int sig_num )
{
    signal(SIGUSR1, sigusr1_handler);
    object->LoadFeedData();
    object->Notify();
}

int main(int argc,char *argv[]) {

    if ( argc != 3 ) {
        cout << "usege start_object <id> <type>" << endl;
        exit(0);
    }

    signal(SIGHUP, sighup_handler);
    signal(SIGUSR1, sigusr1_handler);

    int id=atoi(argv[1]);
    int type=atoi(argv[2]);

    int pid=fork();

    switch ( pid ) {
        case -1:
            cout << "Can't fork" << endl;
            break;
        case 0: 
            break;
        default: 
            exit(0);
    }
   
    cout << "Creating object.." << endl;

    object = ObjectFactory::createObject( id, type );

    cout << "Initing object.." << endl;

    object->Init();

    cout << "Running object.." << endl;

    object->Run();

    return 1;

}

