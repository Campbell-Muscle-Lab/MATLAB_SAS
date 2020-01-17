/* SAS template for a 1 way analysis with a grouping variable */

proc import out = work.all_data
	datafile = "#excel_file_string"
	dbms = xlsx replace;
	sheet = "#excel_sheet";
	getnames=yes;
run;

#ods_string_1
ods listing close;

/*data work.all_data; */
/*	modify work.all_data;*/
/*	if #test_variable = 'NaN' then #test_variable = . ;*/
/*run;*/

proc print data=all_data;
	title1 'All data';
run;

proc glimmix data=all_data;
	class #factor_1 #grouping;
	model #test_variable = #factor_1 /ddfm=satterthwaite;
	random #grouping;
	lsmeans #factor_1 /slice = #factor_1 pdiff adjust=tukey;
run;

ods listing;
#ods_string_2

