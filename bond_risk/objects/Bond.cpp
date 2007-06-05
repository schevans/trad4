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


    }
    _payment_vec.push_back( 100 * _sub_discount_rate->rate[_coupon_date_vec[_coupon_date_vec.size() -1] - TODAY] );

    float price(0.0);

    vector<float>::iterator iter_float;

    for( iter_float = _payment_vec.begin() ; iter_float < _payment_vec.end() ; iter_float++ )
    {

//cout << "Flow: " << *iter_float << " price: " << price << endl;
        price = price + *iter_float;

    }

    SetPrice( price ); 


    Notify();
    return true;
}

Bond::Bond( int id )
{
    cout << "Bond::Bond: "<< id << endl;

//    _pub = (bond*)CreateShmem(sizeof(bond));

    Init( id );
}

