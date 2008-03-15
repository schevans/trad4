
#ifndef __interest_rate_feed__
#define __interest_rate_feed__

#include <sys/types.h>

#include "common.h"


typedef struct {
    int asof[INTEREST_RATE_LEN];
    double rate[INTEREST_RATE_LEN];
    int last_published;
} interest_rate_feed_sub;

typedef struct {
    // Header
    time_t last_published;
    object_status status;
    void* (*calculator_fpointer)(void*);
    bool (*need_refresh_fpointer)(int);
    int type;
    char name[OBJECT_NAME_LEN];

    // Sub

    // Static
    int shmid; 
    interest_rate_feed_sub* sub;
    // Pub
    int asof[INTEREST_RATE_LEN];
    double rate[INTEREST_RATE_LEN];

} interest_rate_feed;

#endif
