
#ifndef __bond__
#define __bond__

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
    int currency_curves;

    // Static
    double coupon;
    int start_date;
    int maturity_date;
    int coupons_per_year;

    // Pub
    double price;
    double dv01;
} bond;

#endif
