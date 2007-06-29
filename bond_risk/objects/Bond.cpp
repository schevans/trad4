#include <sys/ipc.h>
#include <sys/shm.h>
#include <iostream>

#include "Bond.h"

using namespace std;

bool Bond::Calculate()
{
    cout << "Bond::Calculate()" << endl;

    _coupon_date_vec.clear();
    _payment_vec.clear();
    _payment_vec_01.clear();

    int days_between_coupons = (int)YEAR_BASIS / GetCouponsPerYear();
    float coupon_rate_per_period = ( GetCoupon() / 100 ) / GetCouponsPerYear();

    int working_date = GetStartDate();

    while ( working_date < TODAY )
    {
        working_date = working_date + days_between_coupons;
    }

    while ( working_date < GetMaturityDate()  )
    {
        _coupon_date_vec.push_back( working_date );

        working_date = working_date + days_between_coupons;
    }

    _coupon_date_vec.push_back( working_date );

    vector<int>::iterator iter;

    for( iter = _coupon_date_vec.begin() ; iter < _coupon_date_vec.end() ; iter++ )
    {

 //       cout << "Flow: 100.0 * " << coupon_rate_per_period << " * " <<  _sub_discount_rate->rate[*iter - TODAY] << endl;

        _payment_vec.push_back( 100.0 * coupon_rate_per_period * _sub_discount_rate->rate[*iter - TODAY] );

        _payment_vec_01.push_back( 100.0 * coupon_rate_per_period * _sub_discount_rate->rate_01[*iter - TODAY] );


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

    SetPrice( price ); 

cout << "Price: " << price << ", price_01: " << price_01 << endl;


    SetDv01( price - price_01 );

    Notify();
    return true;
}


