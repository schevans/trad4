#ifndef __OPTION_VEC__
#define __OPTION_VEC__

#include "OptionVecBase.h"



class OptionVec : public OptionVecBase {

public:

    OptionVec( int id ) { _id = id; }
    virtual ~OptionVec() {}

    virtual bool Calculate();

};

#endif

