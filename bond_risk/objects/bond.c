// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//


#include <iostream>
#include <vector>

#include "bond_wrapper.c"

using namespace std;

void* calculate_bond( bond* pub_bond, currency_curves* sub_currency_curves )
{
    cout << "calculate_bond()" << endl;

    std::vector<int> _coupon_date_vec;
    std::vector<float> _payment_vec;
    std::vector<float> _payment_vec_01;

    int days_between_coupons = (int)YEAR_BASIS /  pub_bond->coupons_per_year;
    float coupon_discount_rate_per_period = ( pub_bond->coupon / 100 ) / pub_bond->coupons_per_year;

    int working_date = pub_bond->start_date;

    while ( working_date < TODAY )
    {
        working_date = working_date + days_between_coupons;
    }

    while ( working_date < pub_bond->maturity_date  )
    {
        _coupon_date_vec.push_back( working_date );

        working_date = working_date + days_between_coupons;
    }
    _coupon_date_vec.push_back( working_date );

    vector<int>::iterator iter;

    for( iter = _coupon_date_vec.begin() ; iter < _coupon_date_vec.end() ; iter++ )
    {
        _payment_vec.push_back( 100.0 * coupon_discount_rate_per_period * sub_currency_curves->discount_rate[*iter - TODAY] );
        _payment_vec_01.push_back( 100.0 * coupon_discount_rate_per_period * sub_currency_curves->discount_rate_01[*iter - TODAY] );

        //cout << "_payment_vec: " << ( 100.0 * coupon_discount_rate_per_period * sub_currency_curves->discount_rate[*iter - TODAY] ) << endl;
        //cout << "_payment_vec_01: " << ( 100.0 * coupon_discount_rate_per_period * sub_currency_curves->discount_rate_01[*iter - TODAY] ) << endl;
    }

    _payment_vec.push_back( 100 * sub_currency_curves->discount_rate[_coupon_date_vec[_coupon_date_vec.size() -1] - TODAY] );
    _payment_vec_01.push_back( 100 * sub_currency_curves->discount_rate_01[_coupon_date_vec[_coupon_date_vec.size() -1] - TODAY] );

    float price(0.0);
    float price_01(0.0);

    for( unsigned int i = 0 ; i < _payment_vec.size() ; i++ )
    {
        price = price + _payment_vec[i];

        price_01 = price_01 + _payment_vec_01[i];

    }

    pub_bond->price = ( price );
    pub_bond->dv01 = ( price - price_01 );

    cout << "New bond price: " << price << ", dv01: " << ( price - price_01 ) << endl;
}

