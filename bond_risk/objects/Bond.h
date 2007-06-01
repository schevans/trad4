#ifndef __BOND__
#define __BOND__

#include "BondBase.h"



class Bond : public BondBase {

public:

    Bond( int id );
    virtual ~Bond() {}

    virtual bool Calculate();

};

#endif

