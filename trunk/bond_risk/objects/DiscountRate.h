// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __DISCOUNT_RATE__
#define __DISCOUNT_RATE__

#include "DiscountRateBase.h"



class DiscountRate : public DiscountRateBase {

public:

    DiscountRate( int id ) { _id = id; }
    virtual ~DiscountRate() {}

    virtual bool Calculate();

};

#endif

