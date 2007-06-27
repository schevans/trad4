
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

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
            Calculate();
        }

        sleep(GetSleepTime());

    }


}


