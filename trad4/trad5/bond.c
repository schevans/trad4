// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <vector>

#include "trad5.h"
#include "common.h"
#include "bond.h"
#include "discount_rate.h"

using namespace std;

//#define NUM_OBJECTS 3

//extern void* obj_loc[NUM_OBJECTS+1];

extern void set_timestamp( int );

extern void* obj_loc[NUM_OBJECTS+1];


void* calculate_bond( void* id )
{
    cout << "Bond::Calculate()" << endl;

    // Hack to get this working. Otherwise lifted from trad_bond_risk.
    // Also had to inline the accsessors
    void* _pub = obj_loc[(int)id];
    discount_rate* _sub_discount_rate = (discount_rate*)obj_loc[((bond*)_pub)->discount_rate];

    std::vector<int> _coupon_date_vec;
    std::vector<float> _payment_vec;
    std::vector<float> _payment_vec_01;


    int days_between_coupons = (int)YEAR_BASIS /  ((bond*)_pub)->coupons_per_year;
    float coupon_rate_per_period = ( ((bond*)_pub)->coupon / 100 ) / ((bond*)_pub)->coupons_per_year;

    int working_date = ((bond*)_pub)->start_date;

    while ( working_date < TODAY )
    {
        working_date = working_date + days_between_coupons;
    }

    while ( working_date < ((bond*)_pub)->maturity_date  )
    {
        _coupon_date_vec.push_back( working_date );

        working_date = working_date + days_between_coupons;
    }

    _coupon_date_vec.push_back( working_date );

    vector<int>::iterator iter;

    for( iter = _coupon_date_vec.begin() ; iter < _coupon_date_vec.end() ; iter++ )
    {
        _payment_vec.push_back( 100.0 * coupon_rate_per_period * _sub_discount_rate->rate[*iter - TODAY] );
        _payment_vec_01.push_back( 100.0 * coupon_rate_per_period * _sub_discount_rate->rate_01[*iter - TODAY] );

        //cout << "_payment_vec: " << ( 100.0 * coupon_rate_per_period * _sub_discount_rate->rate[*iter - TODAY] ) << endl;
        //cout << "_payment_vec_01: " << ( 100.0 * coupon_rate_per_period * _sub_discount_rate->rate_01[*iter - TODAY] ) << endl;
    }

    _payment_vec.push_back( 100 * _sub_discount_rate->rate[_coupon_date_vec[_coupon_date_vec.size() -1] - TODAY] );
    _payment_vec_01.push_back( 100 * _sub_discount_rate->rate_01[_coupon_date_vec[_coupon_date_vec.size() -1] - TODAY] );

    float price(0.0);
    float price_01(0.0);

    for( unsigned int i = 0 ; i < _payment_vec.size() ; i++ )
    {
        price = price + _payment_vec[i];

        price_01 = price_01 + _payment_vec_01[i];

    }

    ((bond*)_pub)->price = ( price );
    ((bond*)_pub)->dv01 = ( price - price_01 );

    cout << "New bond price: " << price << ", dv01: " << ( price - price_01 ) << endl;

    set_timestamp((int)id);
}

// More-or-less lifted from BondBase::NeedRefresh()
bool bond_need_refresh( int id )
{
    // This will be generated - doesn't matter if it's illegeble.
    return ( ((object_header*)obj_loc[id])->status == STOPPED ) && ( *(int*)obj_loc[id] < *(int*)obj_loc[((bond*)obj_loc[id])->discount_rate] );
}

