BEGIN;
delete from ir_curve_input_rates;
insert into ir_curve_input_rates values ( 1, 0, 10000,2.6 );
insert into ir_curve_input_rates values ( 1, 1, 10010,2.7 );
insert into ir_curve_input_rates values ( 1, 2, 10100,2.7 );
insert into ir_curve_input_rates values ( 1, 3, 10200,2.7 );
insert into ir_curve_input_rates values ( 1, 4, 10300,2.8 );
insert into ir_curve_input_rates values ( 1, 5, 12000,2.8 );
insert into ir_curve_input_rates values ( 1, 6, 13000,2.9 );
insert into ir_curve_input_rates values ( 1, 7, 15000,2.9 );
insert into ir_curve_input_rates values ( 1, 8, 18000,2.8 );
insert into ir_curve_input_rates values ( 1, 9, 20000,2.8 );
insert into ir_curve_input_rates values ( 2, 0, 10000,5.2 );
insert into ir_curve_input_rates values ( 2, 1, 10010,5.3 );
insert into ir_curve_input_rates values ( 2, 2, 10100,5.4 );
insert into ir_curve_input_rates values ( 2, 3, 10200,5.4 );
insert into ir_curve_input_rates values ( 2, 4, 10300,5.5 );
insert into ir_curve_input_rates values ( 2, 5, 12000,5.5 );
insert into ir_curve_input_rates values ( 2, 6, 13000,5.5 );
insert into ir_curve_input_rates values ( 2, 7, 15000,5.4 );
insert into ir_curve_input_rates values ( 2, 8, 18000,5.3 );
insert into ir_curve_input_rates values ( 2, 9, 20000,5.3 );
COMMIT;