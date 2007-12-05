
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE

#include <iostream>
#include <sys/shm.h>
#include <fstream>
#include <signal.h> 

#include "CalcObjectAgg.h"
#include "ObjectFactory.h"

using namespace std;

void CalcObjectAgg::Run() {
    cout << "CalcObjectAgg::Run()" << endl;

    cout << "Attaching to subscriptions..." << endl;

    AttachToSubscriptions();

//    SetStatus( RUNNING );

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


