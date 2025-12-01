/*vytvoříme soubor dle požadavků*/
data sad.cv3_new;
	set sad.cv3;
	keep Yr_Sold SalePrice Age_Sold Garage_Area;
	where Yr_Sold between 2008 and 2010;
	label Yr_Sold="Rok prodeje" 
		SalePrice="Cena nemovitosti v USD" 
		Age_Sold="Stáří domu"
		Garage_Area= "Plocha garáží"; 
run;
/*Ověříme spravnost*/
proc print data=sad.cv3_new (obs=10) label;
run; 
/*Popisné charakteristiky*/
proc univariate data=sad.cv3_new;
    var SalePrice Age_Sold Garage_Area;
    histogram SalePrice Age_Sold Garage_Area / normal;
    title "Interval Variables Distribution Analysis";
run;

/*Bodový graf*/
proc sgscatter data=sad.cv3_new;
    plot SalePrice*Age_Sold / REG =(degree=1 cli);
    title "Associations of Age Sold with Sale Price";
run;
/*Z výsledku můžeme říct, že má negativní korelace a že čím je dům starší (Age_Sold), 
tím má tendenci být jeho prodejní cena (SalePrice) nižší.
Z grafu je vidět že domy jsou poměrně značně rozptýleny kolem regresní přímky. 
To naznačuje, že věk (Age_Sold) není jediným faktorem ovlivňujícím cenu, 
existuje značná variabilita, kterou tento faktor nevysvětluje.*/
proc sgscatter data=sad.cv3_new;
    plot SalePrice*Garage_Area / REG =(degree=1 cli);
    title "Associations of Garage Area with Sale Price";
run;
/*Znamená to, že má pozitivní korelace a že čím je plocha garáže (Garage_Area) větší , 
tím má tendenci být prodejní cena nemovitosti (SalePrice) vyšší.
Nulová hodnota pro Garage_Area je skupina bodů
na levé straně, kde je plocha garáže (Garage_Area) rovna 0.*/

/*Korelační analýza z hlediska statistické významnosti vztahu*/
ods graphics / reset=all imagemap;
proc corr data=sad.cv3_new rank
          nosimple 
          plots(only)=scatter(nvar=all ellipse=none);
   var SalePrice Age_Sold Garage_Area;
   title "Correlations and Scatter Plots with SalePrice";
run;
/*Vztah mezi SalePrice a Age_Sold: Směr vztahu je negativní -0.61513 (koeficient r).
Má silný vztah, protože hodnota je více než 0.6.
Je tento vztah vysoce statisticky významný, protože p-hodnota (<.0001) je méně než 0.05. 
To potvrzuje že čím je dům starší, tím je jeho cena v průměru nižší.*/

/*Vztah mezi SalePrice a Garage_Area: Směr vztahu je pozitivní 0.58518 (koeficient r).
Má středně silný vztah, protože hodnota je více než 0.5 ale nižší než 0.6.
Je tento vztah vysoce statistický významný, protože p-hodnota (<.0001) je méně než 0.05.
To potvrzuje že čím větší je garáž, tím je cena domu v průměru vyšší*/

/*Odhad regresní funkce*/
ods graphics on;

proc reg data=sad.cv3_new alpha=0.05 plots(only)=(diagnostics residuals observedbypredicted);
    model SalePrice=Garage_Area Age_Sold / stb clb;
    title "Model with Garage_Area and Age_Sold";
run;
quit;

/*H0 pro model jako celek: 
Model není významný (ani GarageArea ani AgeSold nemají vliv na SalePrice)
H1: model je statisticky vyznamný (GarageArea nebo AgeSold mají vliv na SalePrice)
Z výsledků vidíme, že Pr>F a zamítáme nulovou hypotézu a model je statisticky významný */

/*H0 pro jednotlivé proměnné: 
H0: b1=b2=b3...=0
H1: b1!=b2!=b3...!=0

Obě proměnné Age_Sold a Garage_Area je <.0001, což znamená že mají vliv na SalePrice, 
zamítáme H0 na základě výsledků, aspoň jeden x je vyznamný. 
Pokud Garage_Area se nezmění a Age_Sold se změní o 1 SalePrice se sniží o 614.37380.
Pokud Age_Sold se nezmění a Garage_Area se změní o 1 SalePrice se zvyší o 81.87204.

R2: Dohromady SalePrice je vysvětlená proměnnámi Garage_Area a Age_Sold z 0.4934~49.3%
Což znamená, že společně vysvětlují 49.3% celkové variability v ceně nemovitosti.
Zbylých 50.7% tvoří jiné faktory.

Age_Sold je více významný než Garage_Area, protože |-0.43826|>|0.38255|, to znamena
že SalePrice je víc ovlivněna Age_Sold než Garage_Area
*/