
#ifndef __outright_trade__
#define __outright_trade__

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

    // Static
    int quantity;
    int trade_date;
    double trade_price;
    int book;

    // Pub
    double pv;
    double pnl;
} outright_trade;

#endif
