
// Copyright (c) Steve Evans 2007
// steve@topaz.myzen.co.uk
// This code is licenced under the LGPL. For details see $TRAD4_ROOT/LICENCE


#ifndef __OBJECT_H__
#define __OBJECT_H__
#include <string>

#include "trad4.h"


class Object {

public:

    virtual ~Object() {}

    void* CreateShmem( size_t pub_size );
    bool AttachToObjLoc();
    bool DetachFromObjLoc();
    bool Notify();
    void CheckSubStatus();

    virtual void Run() = 0;
    virtual void Init();
    virtual bool LoadFeedData() = 0;
    virtual bool Stop() = 0;
    virtual std::string GetName() = 0;
    virtual int GetSleepTime() = 0;
    virtual int SizeOfStruct() = 0;
    virtual int Type() = 0;
    virtual bool Save() = 0;
    virtual bool Calculate() = 0;
    virtual bool AttachToSubscriptions() = 0;

    void SetStatus( object_status status ) { ((object_header*)_pub)->status = status; }
    virtual bool Load() = 0;

    void* GetPub() { return _pub; }

    virtual void ExitOnError();

protected:

    int _id;
    std::string _data_file_name;
    std::string _data_dir;
    obj_loc* _obj_loc;
    int _obj_loc_shmid;
    void* _pub;
    int _shmid;
    bool _shmem_created;
};

#endif
