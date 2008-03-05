
-- MASTER DELETE --
delete from object;
delete from discount_rate;
delete from bond;
delete from interest_rate_feed_data;

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
insert into discount_rate values ( 2, 1 );

insert into object values ( 3, 3, "US81823453" );
insert into bond values ( 3, 2.8, 5000, 15000, 1, 1 );

