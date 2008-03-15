
#include <iostream>
#include <sstream>


#include "trad4.h"
#include "bond.h"
#include "currency_curves.h"

#include "mysql/mysql.h"

extern void* obj_loc[NUM_OBJECTS+1];
extern void* calculate_bond_wrapper( void* id );
extern int create_shmem( void** ret_mem, size_t pub_size );
extern bool bond_need_refresh( int id );
extern int tier_manager[NUM_TIERS+1][NUM_OBJECTS+1];

void load_bond( MYSQL* mysql )
{
    //std::cout << "load_bonds()" << std::endl;

    MYSQL_RES *result;
    MYSQL_ROW row;

    std::ostringstream dbstream;
    dbstream << "select o.id, o.name , t.coupon , t.start_date , t.maturity_date , t.coupons_per_year , t.currency_curves  from object o , bond t  where  o.id = t.id and  o.type = 3";

    if(mysql_query(mysql, dbstream.str().c_str()) != 0) {
        std::cout << __LINE__ << ": " << mysql_error(mysql) << std::endl;
        exit(0);
    }

    result = mysql_use_result(mysql);

    while (( row = mysql_fetch_row(result) ))
    {
        int id = atoi(row[0]);

        obj_loc[id] = new bond;

        ((bond*)obj_loc[id])->last_published = 0;
        ((bond*)obj_loc[id])->status = STOPPED;
        ((bond*)obj_loc[id])->calculator_fpointer = &calculate_bond_wrapper;
        ((bond*)obj_loc[id])->need_refresh_fpointer = &bond_need_refresh;
        ((bond*)obj_loc[id])->type = 3;
        //((bond*)obj_loc[id])->name = 0;
        
        ((bond*)obj_loc[id])->coupon = atof(row[2]);
        ((bond*)obj_loc[id])->start_date = atoi(row[3]);
        ((bond*)obj_loc[id])->maturity_date = atoi(row[4]);
        ((bond*)obj_loc[id])->coupons_per_year = atoi(row[5]);
        ((bond*)obj_loc[id])->currency_curves = atoi(row[6]);

        tier_manager[3][tier_manager[3][0]] = id;
        tier_manager[3][0]++;

        //std::cout << "New bond created." << std::endl;
    }

    mysql_free_result(result);
    std::cout << "Bonds loaded." << std::endl;
}
