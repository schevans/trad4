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

