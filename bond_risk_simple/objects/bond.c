// Copyright (c) Steve Evans 2010
// schevans@users.sourceforge.net
// This code is released under the BSD licence. For details see $APP_ROOT/LICENCE
//

// Please see the comment at the top of bond_risk/gen/objects/bond_macros.h
//  to see what's in-scope.

#include <iostream>
#include <vector>

#include "bond_wrapper.c"

using namespace std;

int calculate_bond( obj_loc_t obj_loc, long id )
{
    // Generate the coupon schedule - the dates of the coupon payments.
    // This is a bit fiddly, as always.

    double days_between_coupons = YEAR_BASIS / bond_coupons_per_year;
    double coupon_rate_per_period = bond_coupon / bond_coupons_per_year;

    std::vector<date> coupon_schedule;
    coupon_schedule.push_back( bond_start_date );

    double coupon_date = bond_start_date;

    while( coupon_date < bond_maturity_date - days_between_coupons )
    {
        coupon_date = coupon_date + days_between_coupons;
        coupon_schedule.push_back((date)floor(coupon_date+0.5));
    } 

    // The schedule is now generated. Next we iterate over it, discounting the future coupon payments
    // and summing the result.
    // We need to do this for price and pv01.
    
    double price(0);
    double price_p01(0);
    double price_m01(0);
    
    std::vector<date>::const_iterator iter = coupon_schedule.begin();
    
    for ( ; iter != coupon_schedule.end() ; iter++ )
    {
        if ( *iter >= calendar_today )   // Only consider payments today and in the future.
        {
            // Calculate the offset we need to index into ir_curve
            int ir_offset = (*iter) - calendar_today;

            // Get the discount_rate from ir_curve 
            double discount_rate = ir_curve_discount_rate[ir_offset];

            // Use the discount_rate to discount the future coupon payments
            price = price + ( 100.0 * coupon_rate_per_period * discount_rate );

            // And calculate the price _p01 and _m01, used to calculate the pv01.
            price_p01 = price_p01 + ( 100.0 * coupon_rate_per_period * ir_curve_discount_rate_p01[ir_offset] );
            price_m01 = price_m01 + ( 100.0 * coupon_rate_per_period * ir_curve_discount_rate_m01[ir_offset] );
        }
    }

    // Add in the principal repayment at maturity
    price = price + ( 100.0 * ir_curve_discount_rate[bond_maturity_date - calendar_today] );
    price_p01 = price_p01 + ( 100.0 * ir_curve_discount_rate_p01[bond_maturity_date - calendar_today] );
    price_m01 = price_m01 + ( 100.0 * ir_curve_discount_rate_m01[bond_maturity_date - calendar_today] );

    // And assign the results
    bond_price = price;
    bond_pv01 = ( price_p01 - price_m01 ) / 2.0;

    return 1;
}

