#!/bin/sh


cd ~/src/test_app
. ./test_app.conf
make clean
t4p -a
make all
cd data
recreate_db.sh
reload_db.sh worked_example
test_app


