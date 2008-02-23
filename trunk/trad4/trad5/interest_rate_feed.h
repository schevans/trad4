// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE
// 

#ifndef __interest_rate_feed__
#define __interest_rate_feed__

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

    // Static
    int ccy;

    // Pub
    int asof[INTEREST_RATE_LEN];
    double rate[INTEREST_RATE_LEN];
    double rate_interpol[DISCOUNT_RATE_LEN];
} interest_rate_feed;

#endif
