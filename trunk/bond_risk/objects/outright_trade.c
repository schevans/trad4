
#include <iostream>

#include "outright_trade_wrapper.c"

using namespace std;

void* calculate_outright_trade( outright_trade* pub_outright_trade , bond* sub_bond )
{
    cout << "calculate_outright_trade()" << endl;

    pub_outright_trade->pv = ( pub_outright_trade->quantity * sub_bond->price / 100 );

    pub_outright_trade->pnl = (( pub_outright_trade->quantity * sub_bond->price / 100 ) - ( pub_outright_trade->quantity * pub_outright_trade->trade_price / 100 ));

    cout << "outright_trade pv=" << pub_outright_trade->pv << ", pnl=" << pub_outright_trade->pnl << endl;
}

