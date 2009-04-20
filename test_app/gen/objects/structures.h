

#ifndef __structures_h__
#define __structures_h__

#include "constants.h"
#include "aliases.h"

typedef struct {
    int d;
    float ha[NUM_RATES];
} ms_inner;

typedef struct {
    ms_inner my_inner_ms[3];
    int ig;
    float fr;
} ms_outer;

typedef struct {
    double rates[NUM_RATES];
    date dates[NUM_RATES];
} struct2;

typedef struct {
    int x;
    float y;
    int iz;
} struct1;


#endif
