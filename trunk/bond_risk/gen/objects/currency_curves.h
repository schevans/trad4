
#ifndef __currency_curves__
#define __currency_curves__

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

    // Pub
    double interest_rate_interpol[DISCOUNT_RATE_LEN];
    double discount_rate[DISCOUNT_RATE_LEN];
    double discount_rate_01[DISCOUNT_RATE_LEN];
} currency_curves;

#endif
