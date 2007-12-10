
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE


#include <iostream>
#include <sys/shm.h>
#include <fstream>
#include <signal.h> 

#include "CalcObjectMgr.h"
#include "ObjectFactory.h"

using namespace std;

void CalcObjectMgr::Run() {
    cout << "CalcObjectMgr::Run()" << endl;

    cout << "Attaching to subscriptions..." << endl;

    while ( ! AttachToSubscriptions() ) {
        SetStatus( BLOCKED );
        cout << GetName() << " can't attach." << endl;
        sleep(GetSleepTime());
    }

    void *element;
    int element_id;

    vector<int>::iterator iter;
    for( iter = _element_ids.begin() ; iter < _element_ids.end() ; iter++ )
    {
        element_id = *iter;

        cout << element_id << ": " <<  _obj_loc->shmid[element_id] << endl;

        if ( _obj_loc->shmid[element_id] == 0 )
        {
            cout << "Element id " << element_id << " unstarted." << endl;
            element = 0;
        }
        else
        {
            if (( element = shmat(_obj_loc->shmid[element_id], NULL, 0)) == (char *) -1) {
                perror("shmat");
                exit(1);
            }

            ((object_header*)(element))->status = STOPPED;

            if ( ((object_header*)(element))->pid != getpid() )
                kill( ((object_header*)(element))->pid, SIGKILL);

        }

        Object* object = ObjectFactory::createObject( element_id, MgrType() );

        object->Init();

        ((object_header*)(object->GetPub()))->last_published = 0;

        if ( object->AttachToSubscriptions() ) 
        {
            object->Calculate();

            ((object_header*)(object->GetPub()))->status = MANAGED;
        }
        else
            ((object_header*)(object->GetPub()))->status = BLOCKED;

        _elements.push_back( object );
    }

    SetStatus( RUNNING );

    while ( 1 ) {

//cout << GetName() << ": Looping.." << endl;
    
        CheckSubscriptions();

        if ( NeedRefresh() )
        {
cout << GetName() << ": Need refresh.." << endl;
            if ( Calculate() )
            {
                Notify();
            }
        }

        sleep(GetSleepTime());

    }


}

bool CalcObjectMgr::Stop()
{
    cout << "Stopping " << GetName() << endl;

    vector<Object*>::iterator iter;
    for( iter = _elements.begin() ; iter < _elements.end() ; iter++ )
    {
        (*iter)->SetStatus( STOPPED );
        (*iter)->Save();
        shmdt( (*iter)->GetPub() );

    }

    SetStatus( STOPPED );

    return true;
}

