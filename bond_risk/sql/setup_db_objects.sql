
-- MASTER DELETE --
delete from object;
delete from currency_curves;
delete from bond;
delete from interest_rate_feed_data;
delete from outright_trade;
delete from repo_trade;

insert into object values ( 1, 1, "LIBOR-USD", 0, 1 );
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


insert into object values ( 2, 2, "DISCO-USD", 0, 1 );
insert into currency_curves values ( 2, 1 );

insert into object values ( 3, 3, "US81823453", 0, 1 );
insert into bond values ( 3, 15000, 5000, 1, 2.8, 2 );

insert into object values ( 4, 4, "O38273", 0, 1 );
insert into outright_trade values ( 4, 102.8, 0, 10000, 9982, 3 );

insert into object values ( 5, 5, "R25745", 0, 1 );
insert into repo_trade values ( 5, 4.25, 0, 12388, 0, 8934, 23427.34, 25000, 3, 2 );

