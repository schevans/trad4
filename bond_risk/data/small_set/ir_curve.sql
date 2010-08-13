BEGIN;
delete from ir_curve;
insert into object values (  1, 1, 1, "LIBOR.USD", 0, 1 );
insert into ir_curve values ( 1 );
insert into object values (  2, 1, 1, "LIBOR.GBP", 0, 1 );
insert into ir_curve values ( 2 );
COMMIT;
