BEGIN;
delete from ir_curve;
insert into object values (  10, 2, 1, "LIBOR.USD", 1, 1 );
insert into ir_curve values ( 10 );
insert into object values (  11, 2, 1, "LIBOR.GBP", 1, 1 );
insert into ir_curve values ( 11 );
COMMIT;
