
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
    virtual void Init( int id ) = 0;
    virtual bool LoadFeedData() = 0;
    virtual bool Stop() = 0;

    virtual void SetObjectStatus( object_status status ) = 0;
    virtual bool Load() = 0;
    virtual int Type() = 0;


protected:

    int _id;
    std::string _name;
    int _shmid;
    int _sleep_time;
    int _log_level;
    std::string _data_file_name;

    obj_loc* _obj_loc;

    void* _pub;

};

#endif
