// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
// 

#ifndef __bond__
#define __bond__

#include <sys/types.h>

typedef struct {
    // Header
    time_t last_published;
    object_status status;
    void* (*calculator_fpointer)(void*);
    bool (*need_refresh_fpointer)(int);
    int type;
    char name[OBJECT_NAME_LEN];
    int sleep_time;

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
