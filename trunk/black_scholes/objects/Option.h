// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the BSD licence. For details see $INSTANCE_ROOT/LICENCE

#ifndef __OPTION__
#define __OPTION__

#include "OptionBase.h"



class Option : public OptionBase {

public:

    Option( int id ) { _id = id; }
    virtual ~Option() {}

    virtual bool Calculate();

private:

    double CalcCumNormDist( double x );
    double nc( double x );
    double ndf( double x );

    double _d1;
    double _d2;

    double _ln_SK;
    double _rT;
    double _v2T_2;
    double _vRtT;
    double _KerT;
    double _rKerT;
    double _Sv;
    double _RtT;

    double _SN_pd1;
    double _SN_md1;
    double _KerTN_pd2;
    double _KerTN_md2;

    double _N_pd1;
    double _N_pd2;
    double _N_md2;


};

#endif

