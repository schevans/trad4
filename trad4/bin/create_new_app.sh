#!/bin/sh

if [ $# -ne 1 ]
then
    echo "create_new_app.sh <app_name>"
    exit 0
fi

NEW_APP=$1

if [ ! -d ../../$NEW_APP ]
then
    mkdir ../../$NEW_APP
fi

if [ ! -d ../../$NEW_APP/src ]
then
    mkdir ../../$NEW_APP/src
fi

if [ ! -d ../../$NEW_APP/data ]
then
    mkdir ../../$NEW_APP/data
fi

if [ ! -f ../../$NEW_APP/$NEW_APP.conf ]
then
    echo > ../../$NEW_APP/$NEW_APP.conf
    echo "echo \"Sourcing $NEW_APP.conf\"" >> ../../$NEW_APP/$NEW_APP.conf
    echo >> ../../$NEW_APP/$NEW_APP.conf
    echo "NUM_THREADS=4; export NUM_THREADS" >> ../../$NEW_APP/$NEW_APP.conf
    echo >> ../../$NEW_APP/$NEW_APP.conf
    echo "APP_ROOT=\`pwd\` ; export APP_ROOT" >> ../../$NEW_APP/$NEW_APP.conf
    echo >> ../../$NEW_APP/$NEW_APP.conf
    echo "APP_DB=\$APP_ROOT/data/$NEW_APP.db; export APP_DB" >> ../../$NEW_APP/$NEW_APP.conf
    echo >> ../../$NEW_APP/$NEW_APP.conf
    echo "TRAD4_ROOT=\$APP_ROOT/../trad4; export TRAD4_ROOT" >> ../../$NEW_APP/$NEW_APP.conf
    echo >> ../../$NEW_APP/$NEW_APP.conf
    echo ". \$TRAD4_ROOT/trad4.conf" >> ../../$NEW_APP/$NEW_APP.conf
    echo >> ../../$NEW_APP/$NEW_APP.conf
    echo "PATH=\$PATH:\$APP_ROOT/bin; export PATH" >> ../../$NEW_APP/$NEW_APP.conf
    echo >> ../../$NEW_APP/$NEW_APP.conf
    echo "SRC_DIR=\$APP_ROOT/src/; export SRC_DIR" >> ../../$NEW_APP/$NEW_APP.conf
fi

if [ ! -f ../../$NEW_APP/src/object_types.t4s ]
then
    echo "#type_id, name" > ../../$NEW_APP/src/object_types.t4s
fi

