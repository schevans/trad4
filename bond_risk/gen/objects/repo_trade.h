
#ifndef __repo_trade__
#define __repo_trade__

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
    int bond;
    int currency_curves;

    // Static
    int start_date;
    int end_date;
    int notional;
    int cash_ccy;
    double rate;
    double cash;
    int book;

    // Pub
    double mtm_pnl;
    double margin;
} repo_trade;

#endif
