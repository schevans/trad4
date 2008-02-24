// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
// 

#ifndef __interest_rate_feed__
#define __interest_rate_feed__

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

    // Static
    int ccy;

    // Pub
    int asof[INTEREST_RATE_LEN];
    double rate[INTEREST_RATE_LEN];
    double rate_interpol[DISCOUNT_RATE_LEN];
} interest_rate_feed;

#endif
