/* Nastavení názvu dat */
data sad.cv1_2_update;
	set sad.cv1_2;
	label ROA = "Rentabilita aktiv"
		VAdded = "Přídaná hodnota výroby";
run;
/* Zobrazení prvních 10 přejmenovaných dat */
proc print data=sad.cv1_2_update (obs=10) label;
run;
/* Změna lables proměnny VAdded */
proc format;
	value VAdded 1="suroviny" 2="polotvary" 3="hromadná výroba" 4="zakázková výroba";
run;
/* Print tabulky s labely jednotlivých obměn */
proc print data=sad.cv1_2_update (obs=10) label;
	format VAdded Vadded.;
run;
/* počet pozorování, aritmetický průměr, medián, směrodatná odchylka, minimum, maximum, 5% percentil, 95% percentil */
proc means data=sad.cv1_2_update (obs=10) n nmiss mean median std min max p5 p95; 
    var ROA;
    class VAdded;
    format VAdded VAdded.;
run;

/* Histogram */

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=SAD.CV1_2_UPDATE;
	title height=14pt "Charakteristika proměnné ROA";
	footnote2 justify=left height=10pt "Source: DÚ";
	histogram ROA /;
	density ROA /;
	yaxis grid;
	format VAdded VAdded.;
run;

ods graphics / reset;
title;
footnote2;
/* Histogram dle VAdded 1*/
proc sgplot data=SAD.CV1_2_UPDATE;
	title height=14pt "Charakteristika proměnné ROA dle surovin";
	where VAdded = 1;
	footnote2 justify=left height=10pt "Source: DÚ";
	histogram ROA / group = VAdded;
	density ROA /;
	yaxis grid;
	format VAdded VAdded.;
run;
/* Histogram dle VAdded 2*/
proc sgplot data=SAD.CV1_2_UPDATE;
	title height=14pt "Charakteristika proměnné ROA dle polotvarů";
	where VAdded = 2;
	footnote2 justify=left height=10pt "Source: DÚ";
	histogram ROA / group = VAdded;
	density ROA /;
	yaxis grid;
	format VAdded VAdded.;
run;
/* Histogram dle VAdded 3*/
proc sgplot data=SAD.CV1_2_UPDATE;
	title height=14pt "Charakteristika proměnné ROA dle hromadné výroby";
	where VAdded = 3;
	footnote2 justify=left height=10pt "Source: DÚ";
	histogram ROA / group = VAdded;
	density ROA /;
	yaxis grid;
	format VAdded VAdded.;
run;
/* Histogram dle VAdded 4*/
proc sgplot data=SAD.CV1_2_UPDATE;
	title height=14pt "Charakteristika proměnné ROA dle zakázkové výroby";
	where VAdded = 4;
	footnote2 justify=left height=10pt "Source: DÚ";
	histogram ROA / group = VAdded;
	density ROA /;
	yaxis grid;
	format VAdded VAdded.;
run;

/* Krabicový graf */

ods graphics / reset width=6.4in height=4.8in imagemap;

proc sgplot data=sad.cv1_2_update;
	title height=14pt "Charakteristika proměnné ROA";
	footnote2 justify=left height=10pt "Source: DÚ";
	hbox ROA / category=VAdded;
	xaxis grid;
	format VAdded VAdded.;
run;

ods graphics / reset;
title;
footnote2;