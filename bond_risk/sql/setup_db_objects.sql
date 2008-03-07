
-- MASTER DELETE --
delete from object;
delete from currency_curves;
delete from bond;
delete from interest_rate_feed_data;
delete from outright_trade;
delete from repo_trade;

insert into object values ( 1, 1, "LIBOR-USD" );
insert into interest_rate_feed_data values ( 1, 10000, 2.4 );
insert into interest_rate_feed_data values ( 1, 10010, 2.5 );
insert into interest_rate_feed_data values ( 1, 10100, 2.6 );
insert into interest_rate_feed_data values ( 1, 10200, 2.5 );
insert into interest_rate_feed_data values ( 1, 10400, 2.5 );
insert into interest_rate_feed_data values ( 1, 11000, 2.4 );
insert into interest_rate_feed_data values ( 1, 12000, 2.3 );
insert into interest_rate_feed_data values ( 1, 13000, 2.3 );
insert into interest_rate_feed_data values ( 1, 15000, 2.2 );
insert into interest_rate_feed_data values ( 1, 20000, 2.2 );


insert into object values ( 2, 2, "DISCO-USD" );
insert into currency_curves values ( 2, 1 );

insert into object values ( 3, 3, "US81823453" );
insert into bond values ( 3, 2.8, 5000, 15000, 1, 2 );

insert into object values ( 4, 4, "O38273" );
insert into outright_trade values ( 4, 10000, 9982, 102.8, 0, 3 );

insert into object values ( 5, 5, "R25745" );
insert into repo_trade values ( 5, 8934, 12388, 25000, 3, 4.25, 23427.34, 0, 3, 2 );

