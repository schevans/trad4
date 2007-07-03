// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __BOND__
#define __BOND__

#include <vector>


#include "BondBase.h"



class Bond : public BondBase {

public:

    Bond( int id ) { _id = id; }
    virtual ~Bond() {}

    virtual bool Calculate();

private:

    // Calculate
    std::vector<int> _coupon_date_vec;
    std::vector<float> _payment_vec;
    std::vector<float> _payment_vec_01;

};

#endif

