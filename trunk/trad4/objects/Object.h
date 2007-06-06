
// Copyright Steve Evans 2007
// steve@topaz.myzen.co.uk

#ifndef __OBJECT_H__
#define __OBJECT_H__
#include <string>

#include "trad4.h"


class Object {

public:

    virtual ~Object() {}

    void* CreateShmem( size_t pub_size );
    bool AttachToObjLoc();
    bool Notify();

    virtual void Run() = 0;
    virtual void Init();
    virtual bool LoadFeedData() = 0;
    virtual bool Stop() = 0;
    virtual int GetSleepTime() = 0;
    virtual int SizeOfStruct() = 0;
    virtual int Type() = 0;

    void SetStatus( object_status status ) { ((object_header*)_pub)->status = status; }
    virtual bool Load() = 0;


protected:

    int _id;
    std::string _data_file_name;
    obj_loc* _obj_loc;
    void* _pub;
    int _shmid;

    // XXX 
    std::string _name;

};

#endif
