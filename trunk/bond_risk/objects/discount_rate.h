
#ifndef __discount_rate__
#define __discount_rate__

#include <sys/types.h>

#include "common.h"

typedef struct {
    // Header
    ulong last_published;
    object_status status;
    void* (*calculator_fpointer)(void*);
    bool (*need_refresh_fpointer)(int);
    int type;
    char name[OBJECT_NAME_LEN];

    // Sub
    int interest_rate_feed;

    // Static
    int ccy;

    // Pub
    double rate[DISCOUNT_RATE_LEN];
    double rate_01[DISCOUNT_RATE_LEN];
} discount_rate;

#endif
