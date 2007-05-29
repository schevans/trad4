
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#include <iostream>
#include <sstream>
#include <unistd.h>    
#include <sys/types.h> 
#include <signal.h>    

#include "../objects/Object.h"
#include "../objects/ObjectFactory.h"

using namespace std;

auto_ptr<Object> object;

void sighup_handler(int sig_num)
{
    object->Save();
    exit(0);
}

int main(int argc,char *argv[]) {

    if ( argc != 3 ) {
        cout << "usege start_object <id> <type>" << endl;
        exit(0);
    }

    signal(SIGHUP, sighup_handler);

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

    cout << "About to ObjectFactory::createObject: id=" << id << ", type=" << type << endl;

    object = ObjectFactory::createObject( id, type );

    cout << "About to object->Run()" << endl;

    object->Run();

    return 1;

}

