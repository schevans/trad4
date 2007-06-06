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

};

#endif

