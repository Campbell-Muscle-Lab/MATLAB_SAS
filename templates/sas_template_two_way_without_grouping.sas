/* SAS template for a 2 way analysis without a grouping variable */

proc import out = work.all_data
	datafile = "#excel_file_string"
	dbms = xlsx replace;
	sheet = "#excel_sheet";
	getnames=yes;
run;

#ods_string_1
ods listing close;

proc print data=all_data;
	title1 'All data';
run;

proc glimmix data=all_data;
	class #factor_1 #factor_2;
	model #test_variable = #factor_1 #factor_2 #factor_1*#factor_2 /ddfm=satterthwaite;
	lsmeans #factor_1 #factor_2 #factor_1*#factor_2 /slice = #factor_1 slice = #factor_2 slicediff=(#factor_1 #factor_2) pdiff adjust=tukey;
run;

ods listing;
#ods_string_2

