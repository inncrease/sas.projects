/* Vytvoření nového datového souboru */
TITLE 'Tabulka 1: Ukázka dat';

data sad.cv2_2;
	set sad.cv2;
	keep cntry trstplt polintr;
	where cntry in ("CZ", "SK", "HU");
	label cntry="Country" 
		polintr="Zájem o politiku" 
		trstplt="Důvěra v politiky"; 
    if polintr >= 7 then polintr=.;
	if trstplt>=77 then trstplt=.;
run;

proc print data=sad.cv2_2 (obs=10) label;
run;

TITLE; 
/* Nastavení obměn */
proc format;
	value polintr 1="Velmi se zajímá" 2= "Docela se zajímá" 3="Málo se zajímá" 4="Vůbec se nezajímá";
	value trstplt 0="Vůbec nedůvěřuje" 10="Úplně důvěřuje";
run;

/* Print tabulky s labely jednotlivých obměn*/
TITLE 'Tabulka 2: Ukázka dat s labely';

proc print data=sad.cv2_2 (obs=10) label;
	format polintr polintr.
	       trstplt trstplt.;	       
run;

TITLE;
/* Kontingenční tabulka */

proc freq data=sad.cv2_2;
    tables polintr trstplt
           polintr*trstplt / expected nopercent nocol plots(only)=freqplot(scale=percent);
    format polintr polintr.
	       trstplt trstplt.;
run;

/*Graf relativní četnosti*/
TITLE 'Graf 1: Graf relativní četnosti';

proc sgplot data=sad.cv2_2;
  vbar polintr / group=trstplt groupdisplay=cluster stat=percent;
  xaxis label="Zájem o politiku";
    yaxis label="Řádková procenta";
    format polintr polintr.;
run;

TITLE;
/* Rekódování proměnných */
data sad.cv2_2;
	set sad.cv2_2;
	select (polintr);
		when (1) polintr_rec=4;
		when (2) polintr_rec=3;
		when (3) polintr_rec=2;
		when (4) polintr_rec=1;
		otherwise polintr_rec=polintr;
	end;
run;

/*Označení obměn znaků v proměnných*/
proc format;
	value  polintr_rec 4="Velmi se zajímá" 3= "Docela se zajímá" 2="Málo se zajímá" 1="Vůbec se nezajímá";
	value  trstplt 0="Vůbec nedůvěřuje" 9="Úplně důvěřuje";
run;

/*Ověření spravnosti rekódovaní*/
TITLE 'Tabulka 3: Ukázka dat po rekódovaní proměnných a nastavení obměn znaků';

proc print data=sad.cv2_2 (obs=10) label;
	label polintr_rec= 'Zájem o politiku(NEW)';
	format polintr_rec polintr_rec.
	       trstplt trstplt.;	       
run;

TITLE;
/*Nulová hypotéza H0: Mezi zájmem o politiku a důvěrou v politiky NEEXISTUJE statisticky významný vztah*/
/*Alternativní hypotéza H1: Mezi zájmem o politiku a důvěrou v politiky EXISTUJE statisticky významný vztah*/

/* Chi-kvadrát a míra asociace */
proc freq data=sad.cv2_2;
    tables polintr_rec trstplt
           polintr_rec*trstplt / chisq measures expected nopercent nocol cellchi2 plots(only)=freqplot(scale=percent);
    format polintr_rec polintr_rec.
           trstplt trstplt.;
run;

/* Na základě výsledků, Mantel-Haenszel Chi-Square (pro ordinální proměnné) =160,613, zamítáme nulovou hypotézu H0 a přijímáme alternativní hypotézu H1 => vztah mezi Zájmem o politiku a Důvěrou v politiky má silnou lineární složku. */
/* Protože hodnota Mantel-Haenszelova Chi-Square je statisticky vysoce významná (0.0001 < 0.05). */

