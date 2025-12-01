/*1. použití metody FORWARD*/
%let interval=roky_praxe vzdelani pocet_projektu hodnoceni_vykon 
         vek vzdalenost_domu pocet_skoleni delka_dovolene;
         
ods graphics on;

proc glmselect data=sad.cv4_3 plots=all;
	FORWARD: model mzda=&interval / showpvalues selection=forward /*mzda je zavislá proměnná*/
		details=steps select=SL slentry=0.01; /*hladina významnosti je 0.01*/
	title "Forward Model Selection for Mzda - SL 0.01";
run;
/*Z výsledku plýne, že do regresního modelu zařadíme 4 proměnné: roky_praxe, vzdelani, počet projektu, hodnoceni_vykon*/
/*Výsledný model vysvětluje přibližně 74.3 % variability mezd (R-Square=0.7430)*/
/*v kroku 0 model obsahuje pouze absolutní člen - intercept

v kroku 1 do modelu vstupuje proměnná vzdelani (má silnější statistickou významnost: LogpValue =|-65.5375| p<0.0001)

v kroku 2 do modelu vstupuje roky_praxe (má silnější statistickou významnost (již bez vzdelani): LogpValue =|-51.8801| p<0.0001)

v kroku 3 do modelu vstupuje hodnoceni_vykon (má silnější statistickou významnost (bez vzdelani a bez roky_praxe): LogpValue =|-51.2966| p<0.0001)

v kroku 4 do modelu vstoupil pocet_projektu (má LogpValue |-42.6228| p<0.0001)

Stop Criterion: proměnná delka_dovolene má p 0.0486 což je větší 0.01 a proto výběr byl ukončen*/

/*2. Interpretujte bodové odhady regresních koeficientů finálního modelu*/
/* mzda je uvedena v tisících Kč
roky_praxe: s každým dalším rokem pracovní praxe se průměrná měsíční mzda zaměstnance zvyšuje o 893.2 Kč (Estimate = 0.893200)

vzdelani: každý dodatečný rok vzdělání přináší průměrný nárůst měsíční mzdy o 2 596.331 Kč (Estimate = 2.596331)

hodnoceni_vykon: zvýšení hodnocení výkonu o jeden bod je spojeno s nárůstem mzdy v průměru o 2 613.922 Kč (Estimate = 2.613922)

pocet_projektu: každý další projekt zvyšuje průměrnou měsíční mzdu o 1 323.976 Kč (Estimate = 1.323976)*/

/*3. předpoklad finálního modelu - Whiteův test*/
/* homoskedasticita */
/*Sestavíme H0 a H1: 
H0: Rozptyl reziduí je konstantní
H1: Rozptyl reziduí není konstantní*/
ods graphics on;

proc reg data=sad.cv4_3;
	model mzda=roky_praxe vzdelani pocet_projektu 
    	hodnoceni_vykon / stb clb /*interval spolehlivosti*/ spec/*test homoskedasticidy*/;
	title 'Mzda Model - Plots of Diagnostic Statistics';
	run;
quit;
/*Na základě výsledku Whiteův testu přijímáme nulovou hypotézu: Pr > ChiSq 0.1507>0.05, 
lze tvrdit že homoskedasticita je splněna*/

/*Diagnostika reziduí*/
ods graphics on;

proc reg data=sad.cv4_3 plots(only)=(QQ RESIDUALBYPREDICTED COOKSD DFFITS);
    model mzda=roky_praxe vzdelani pocet_projektu 
    	hodnoceni_vykon / stb clb spec;       
    		output out=RegOut rstudent=RStudent dffits=DFFits cookd=CooksD;
    title 'Diagnostika reziduí mzdy';
run;
quit;

/*Z Q-Q Plot of reziduals for mzda je vidět, že body leží téměř přesně na diagonální přímce. 
To potvrzuje, že rezidua mají normální rozdělení*/

/*kolinearita pomocí VIF*/
ods graphics on;
proc reg data=sad.cv4_3;
	model mzda= roky_praxe vzdelani pocet_projektu hodnoceni_vykon / stb clb tol vif ;
	title 'Collinearity diagnostics';
	run;
quit;
/*Použiváme faktor inflace rozptylu (VIF). 

roky_praxe: VIF = 1.00363

vzdelani: VIF = 1.00492

pocet_projektu: VIF = 1.00548

hodnoceni_vykon: VIF = 1.00408

Všechny hodnoty VIF jsou extrémně blízké hodnotě 1 
To znamená, že mezi nezávisle proměnnými neexistuje téměř žádná lineární závislost. 
předpoklad nezávislosti prediktorů je splněn*/

/*Cooks D a DFFITS*/
ods graphics on;
proc reg data=sad.cv4_3 plots(only label)= (RSTUDENTBYPREDICTED COOKSD DFFITS);
	model mzda=mzda=roky_praxe vzdelani pocet_projektu 
    	hodnoceni_vykon / stb clb spec;
	output out=RegOut rstudent=RStudent dffits=DFFits cookd=CooksD;
	title 'Mzda Model - Plots of Diagnostic Statistics';
	run;
quit;

proc means data=work.regout maxdec=3;
var CooksD DFFits;
run;

/*Limit CooksD: 0.0133 (4/300)

Limit DFFits: +-0.258 (5/300 => (0.01666)^0.5 => 2*0.1291)

Pro CooksD maximum je 0.048 což je větší než 0.0133 => existují pozorování, které ovlivňují model

Pro DFFits minimum je -0.413 a maximum je 0.497, obě absolutní hodnoty je větší než 0.258 => existují pozorování, které ovlivňují model

Celkem lze říct, že existují zaměstnanci, kteří silně ovlivňují model svými hodnotami 
*/