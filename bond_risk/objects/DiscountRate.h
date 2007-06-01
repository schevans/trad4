#ifndef __DISCOUNT_RATE__
#define __DISCOUNT_RATE__

#include "DiscountRateBase.h"



class DiscountRate : public DiscountRateBase {

public:

    DiscountRate( int id );
    virtual ~DiscountRate() {}

    virtual bool Calculate();

};

#endif

