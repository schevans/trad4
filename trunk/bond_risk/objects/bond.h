
#ifndef __bond__
#define __bond__

#include <sys/types.h>

#include "common.h"


//void* calculate_bond( void* id );

/*
void* calculate_bond( void* id )
{
//ff
}
*/

typedef struct {
    // Header
    ulong last_published;
    object_status status;
    void* (*calculator_fpointer)(void*);
    bool (*need_refresh_fpointer)(int);
    int type;
    char name[OBJECT_NAME_LEN];

    // Sub
    int discount_rate;

    // Static
    double coupon;
    int start_date;
    int maturity_date;
    int coupons_per_year;
    int ccy;

    // Pub
    double price;
    double dv01;
} bond;

#endif
