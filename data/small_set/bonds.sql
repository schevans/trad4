BEGIN;
delete from bond;
insert into object values (  201, 3, 2, "UK312894725", 1, 1 );
insert into bond values (  201, 37756,45061,2,1.59,1, 11);
insert into object values (  202, 3, 2, "UK298671424", 1, 1 );
insert into bond values (  202, 33218,40523,2,0.14,1, 11);
insert into object values (  203, 3, 2, "UK34158410", 1, 1 );
insert into bond values (  203, 39586,46891,1,1.85,1, 11);
insert into object values (  204, 3, 2, "US235632480", 1, 1 );
insert into bond values (  204, 38838,46143,4,1.53,1, 10);
insert into object values (  205, 3, 2, "US915766195", 1, 1 );
insert into bond values (  205, 33634,40939,2,1.14,1, 10);
COMMIT;
