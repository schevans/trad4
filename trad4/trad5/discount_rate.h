// Copyright (c) Steve Evans 2008
// steve@topaz.myzen.co.uk
// 

#ifndef __discount_rate__
#define __discount_rate__

#include <sys/types.h>
#include "trad4.h"

typedef struct {
    // Header
    time_t last_published;
    object_status status;
    int pid;
    int type;
    char name[OBJECT_NAME_LEN];
    int sleep_time;

    // Sub
    int interest_rate_feed;

    // Static
    int ccy;

    // Pub
    double rate[DISCOUNT_RATE_LEN];
    double rate_01[DISCOUNT_RATE_LEN];
} discount_rate;

#endif
