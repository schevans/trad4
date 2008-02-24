// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
//

#include <iostream>
#include <pthread.h>
#include <stdlib.h>
#include <math.h>
#include <vector>

#include "trad5.h"
#include "common.h"
#include "bond.h"
#include "discount_rate.h"
#include "interest_rate_feed.h"

using namespace std;

#define NUM_OBJECTS 3

void* obj_loc[NUM_OBJECTS+1];

// Temp. Don't know why this isn't being pulled in from trad5.h as other things (like DBG) are..
typedef struct {
    // Header
    time_t last_published;
    object_status status;
    void* (*calculator_fpointer)(void*);
    bool (*need_refresh_fpointer)(int);
    int type;
    char name[OBJECT_NAME_LEN];
    int sleep_time;
} header;

void fire_object( int id );
void run();

// For prototype only 
//  Mimics the IR feed.
void bump_rates();
//  Loads data into memory
void setup_mem();

// This is only called by the master thread, but it's a reader, so that's ok.
// These will be generated by trad5.
bool bond_need_refresh( int id );
bool discount_rate_need_refresh( int id );

// This is only ever called from the object threads, as it's a writer.
void set_timestamp( int id );

// Provided by the user.
void* calculate_bond( void* id );
void* calculate_discount_rate( void* id );
void* calculate_interest_rate_feed( void* id );

int main() {

    setup_mem();

    // Fire off the feed once and let it terminate. This will populate rate_interpol
    fire_object( 1 );

    run();

}

void setup_mem() 
{
    obj_loc[1] = new interest_rate_feed;
    ((interest_rate_feed*)obj_loc[1])->last_published = 0;
//    ((interest_rate_feed*)obj_loc[1])->object_status = 0;
    ((interest_rate_feed*)obj_loc[1])->calculator_fpointer = &calculate_interest_rate_feed;
    ((interest_rate_feed*)obj_loc[1])->need_refresh_fpointer = 0; // It's a feed.
    ((interest_rate_feed*)obj_loc[1])->type = 0;
//    ((interest_rate_feed*)obj_loc[1])->name = 0;
    ((interest_rate_feed*)obj_loc[1])->sleep_time = 0;

    ((interest_rate_feed*)obj_loc[1])->ccy = 0;

    ((interest_rate_feed*)obj_loc[1])->asof[0] = 10000;
    ((interest_rate_feed*)obj_loc[1])->asof[1] = 11000;
    ((interest_rate_feed*)obj_loc[1])->asof[2] = 12000;
    ((interest_rate_feed*)obj_loc[1])->asof[3] = 13000;
    ((interest_rate_feed*)obj_loc[1])->asof[4] = 14000;
    ((interest_rate_feed*)obj_loc[1])->asof[5] = 15000;
    ((interest_rate_feed*)obj_loc[1])->asof[6] = 16000;
    ((interest_rate_feed*)obj_loc[1])->asof[7] = 17000;
    ((interest_rate_feed*)obj_loc[1])->asof[8] = 18000;
    ((interest_rate_feed*)obj_loc[1])->asof[9] = 20000;

    ((interest_rate_feed*)obj_loc[1])->rate[0] = 2.3;
    ((interest_rate_feed*)obj_loc[1])->rate[1] = 2.4;
    ((interest_rate_feed*)obj_loc[1])->rate[2] = 2.5;
    ((interest_rate_feed*)obj_loc[1])->rate[3] = 2.5;
    ((interest_rate_feed*)obj_loc[1])->rate[4] = 2.4;
    ((interest_rate_feed*)obj_loc[1])->rate[5] = 2.3;
    ((interest_rate_feed*)obj_loc[1])->rate[6] = 2.2;
    ((interest_rate_feed*)obj_loc[1])->rate[7] = 2.2;
    ((interest_rate_feed*)obj_loc[1])->rate[8] = 2.2;
    ((interest_rate_feed*)obj_loc[1])->rate[9] = 2.1;

    cout << "New interest_rate_feed created" << endl;
    
    obj_loc[2] = new discount_rate;

    ((discount_rate*)obj_loc[2])->last_published = 0;
//    ((discount_rate*)obj_loc[2])->object_status = 0;
    ((discount_rate*)obj_loc[2])->calculator_fpointer = &calculate_discount_rate;
    ((discount_rate*)obj_loc[2])->need_refresh_fpointer = &discount_rate_need_refresh;
    ((discount_rate*)obj_loc[2])->type = 0;
//    ((discount_rate*)obj_loc[2])->name = 0;
    ((discount_rate*)obj_loc[2])->sleep_time = 0;

    ((discount_rate*)obj_loc[2])->interest_rate_feed = 1;
    ((discount_rate*)obj_loc[2])->ccy = 0;

    cout << "New discount_rate created" << endl;

    obj_loc[3] = new bond;

    ((bond*)obj_loc[3])->last_published = 0;
//    ((bond*)obj_loc[3])->object_status = 0;
    ((bond*)obj_loc[3])->calculator_fpointer = &calculate_bond;
    ((bond*)obj_loc[3])->need_refresh_fpointer = &bond_need_refresh;
    ((bond*)obj_loc[3])->type = 0;
//    ((bond*)obj_loc[3])->name = 0;
    ((bond*)obj_loc[3])->sleep_time = 0;

    ((bond*)obj_loc[3])->discount_rate = 2;
    ((bond*)obj_loc[3])->coupon = 2.2;
    ((bond*)obj_loc[3])->start_date = 5000;
    ((bond*)obj_loc[3])->maturity_date = 15000;
    ((bond*)obj_loc[3])->coupons_per_year = 4;
    ((bond*)obj_loc[3])->ccy = 0;
    ((bond*)obj_loc[3])->price = 0.0;
    ((bond*)obj_loc[3])->dv01 = 0.0;

    cout << "New bond created" << endl;
}

void fire_object( int id )
{
    pthread_t t1;

    if ( pthread_create(&t1, NULL, (*((header*)obj_loc[id])->calculator_fpointer), (void *)id) != 0 ) {
        cout << "pthread_create() error" << endl;
        abort();
    }
}

void* calculate_interest_rate_feed( void* id )
{
    cout << "InterestRateFeed::LoadFeedData()" << endl;


    // Hack to get this working. Otherwise lifted from trad_bond_risk.
    void* _pub = obj_loc[(int)id];

    int current_period_start;
    int current_period_end;

    double gradient;
    double y_intercept;

    for ( int indx = 0; indx < INTEREST_RATE_LEN - 1 ; indx++)
    {
        current_period_start = ((interest_rate_feed*)_pub)->asof[indx];
        current_period_end = ((interest_rate_feed*)_pub)->asof[indx+1];

        gradient = (( ((interest_rate_feed*)_pub)->rate[indx] - ((interest_rate_feed*)_pub)->rate[indx+1] ) / ( ((interest_rate_feed*)_pub)->asof[indx] - ((interest_rate_feed*)_pub)->asof[indx+1] ) );
        y_intercept = ((interest_rate_feed*)_pub)->rate[indx] - gradient * ((interest_rate_feed*)_pub)->asof[indx];

        for ( int i = current_period_start ; i <= current_period_end ; i++ )
        {
            //cout << "\tDate " << i << " index  " << i - DATE_RANGE_START << " rate: " <<(  i*gradient + y_intercept ) << endl;
            ((interest_rate_feed*)_pub)->rate_interpol[i - DATE_RANGE_START] = (  i*gradient + y_intercept );

        }

    }

    set_timestamp((int)id);
}

void* calculate_discount_rate( void* id )
{
    // Hack to get this working. Otherwise lifted from trad_bond_risk.
    void* _pub = obj_loc[(int)id];
    interest_rate_feed* _sub_interest_rate_feed = (interest_rate_feed*)obj_loc[((discount_rate*)_pub)->interest_rate_feed];

    cout << "DiscountRate::Calculate()" << endl;

    for ( int i = 0 ; i < DATE_RANGE_LEN ; i++ )
    {
        //cout << "Libor: " << _sub_interest_rate_feed->rate_interpol[i] << ", Disco: " << exp( -_sub_interest_rate_feed->rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) ) << " Year frac: " << ( i/ YEAR_BASIS ) << endl;

        ((discount_rate*)_pub)->rate[i] = exp( -_sub_interest_rate_feed->rate_interpol[i] * (( i / YEAR_BASIS)/ YEAR_BASIS ) );

        ((discount_rate*)_pub)->rate_01[i] = exp( -(_sub_interest_rate_feed->rate_interpol[i] -0.0001) * (( i / YEAR_BASIS)/ YEAR_BASIS ) );
    }

    set_timestamp((int)id);
}

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

    ((bond*)_pub)->price = ( price ); 

cout << "New bond price: " << price << ", price_01: " << price_01 << endl;

    ((bond*)_pub)->dv01 = ( price - price_01 );

    set_timestamp((int)id);
}

void set_timestamp( int id )
{
    time_t temp;
    (void) time(&temp);

    // I know this looks strange but we 'know' the first element in the struct (pointed to
    //  by obj_loc[id]) is an int, regardless of the type of the struct.
    *(int*)obj_loc[id] = temp;
}

void run()
{
    int bump_rates_counter(1);
    
    while (1) 
    {
        for ( int i=1 ; i <= NUM_OBJECTS ; i++ )
        {
            // First check if the object *has* a need_refresh_fpointer
            //  If it doesn't it's a feed.
            if ( ((header*)obj_loc[i])->need_refresh_fpointer )
            {
                // Ok it's a CaclObject. Call the function.
                if ( (*((header*)obj_loc[i])->need_refresh_fpointer)(i) )
                {
                    fire_object( i );            
                }
            }

            // The sleep's just here to slow things down.
            sleep( 1 );

            // Bump rates every 5 sleeps to simulate market moving.
            if ( bump_rates_counter++ % 5 == 0 )
            {
                bump_rates();
                fire_object( 1 );
            }

        }
    }
}

// More-or-less lifted from BondBase::NeedRefresh()
bool bond_need_refresh( int id )
{
    // This will be generated - doesn't matter if it's illegeble.
    return ( *(int*)obj_loc[id] < *(int*)obj_loc[((bond*)obj_loc[id])->discount_rate] );
}


// More-or-less lifted from DiscountRateBase::NeedRefresh()
bool discount_rate_need_refresh( int id )
{
    // This will be generated - doesn't matter if it's illegeble.
    return ( *(int*)obj_loc[id] < *(int*)obj_loc[((discount_rate*)obj_loc[id])->interest_rate_feed] );
}


// For prototype only - mimics the IR feed.
// In the final version I'll probably put the feed structs in shmem so other processes can write to them.
void bump_rates()
{
    cout << "Rates bumped" << endl;

    double peturbation = ( rand() / (double)RAND_MAX ) - 0.5;

    for ( int i=0 ; i < INTEREST_RATE_LEN ; i++ )
    {
        ((interest_rate_feed*)obj_loc[1])->rate[i] =+ peturbation;
    }
}




