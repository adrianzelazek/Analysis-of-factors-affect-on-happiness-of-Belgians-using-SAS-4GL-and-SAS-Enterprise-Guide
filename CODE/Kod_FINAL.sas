/*scie¿ka do danych*/
%let sciezka=C:\Users\adria\Desktop\reglog;
/*sciezka do folderu z wynikami*/
%let wynik=C:\Users\adria\Desktop\reglog\Nowy folder;
/*Przypisanie biblioteki BE*/
LIBNAME BE BASE "&sciezka";

/*Tworzenie zbiorów z danymi, na podstawie których bêdziemy pracowaæ*/

/*Zbiór ze wszystkimi zmiennymi bez zaaplkikowania formatowania*/
DATA ALL_NOFORMAT;
	SET BE.ESS9BE;
RUN;

/*Utworzenie zbioru ALL_FORMAT*/
%include "&sciezka\ESS9e01_1_formats.sas";
%include "&sciezka\ESS9e01_1_ms.sas";


/*usuniêcie pustych wratoœci, Utworzenie zbioru ALL_FORMAT_NOMISS*/
%include "&sciezka\ESS_miss.sas";

/*utworzenie zbioru ze zmiennymi, które wybraliœmy do analizy (na niesformatowanym zbiorze)*/
DATA OUR_NOFORMAT;
	SET ALL_NOFORMAT;
	KEEP idno happy agea gndr eisced mnactic hinctnta health rlgdgr polintr lrscale sclmeet atncrse ipgdtim impfree anvcld hincfel atchctr evmar ctzcntr stfdem imbgeco ipudrst nwspol;
RUN;

/*Badanie korelacji zmiennych*/
proc corr
data=OUR_NOFORMAT ;
VAR  happy agea gndr eisced mnactic hinctnta health rlgdgr polintr lrscale sclmeet atncrse ipgdtim impfree  anvcld  hincfel atchctr evmar ctzcntr stfdem imbgeco ipudrst nwspol;
RUN;

/*utworzenie zbioru ze zmiennymi, które wybraliœmy do analizy (na sformatowanym zbiorze)*/
DATA OUR_FORMAT;
	SET ALL_FORMAT;
	KEEP  idno happy agea gndr eisced mnactic hinctnta health rlgdgr      polintr  lrscale sclmeet  atncrse  ipgdtim impfree    anvcld  hincfel atchctr   evmar  ctzcntr  stfdem imbgeco ipudrst nwspol;
RUN;

/*utworzenie zbioru ze zmiennymi, które wybraliœmy do analizy (na sformatowanym zbiorze bez pustych obserwacji)*/
DATA OUR_FORMAT_NOMISS;
	SET ALL_FORMAT_NOMISS;
	KEEP  idno happy agea gndr eisced mnactic hinctnta health rlgdgr      polintr  lrscale sclmeet  atncrse  ipgdtim impfree    anvcld  hincfel atchctr   evmar  ctzcntr  stfdem imbgeco ipudrst nwspol;
RUN;

/*Wykres s³upkowy dla zmiennej happy*/
proc sgplot
data=OUR_FORMAT_NOMISS;
vbar happy;
run;

/*Tworzenie zmiennej zerojedynkowej ze zmiennej happy -> 0 - nieszczesliwy , 1- bardzo szczesliwy*/
DATA OUR_FORMAT_NOMISS2;
	SET OUR_FORMAT_NOMISS;
	if happy =<7 then  
		HPI = 0;
	if happy >7 then    
		HPI = 1;
run;

/*Makro do generowania Histogramów*/
%macro plot(zmienna);
	title "Histogram zmiennej: &zmienna.";
	proc sgplot data=work.our_format_nomiss2;
		vbar &zmienna. / group=HPI;
	styleattrs datacolors=( red lightgreen);
	run;
	title;
%mend plot;

/*wygenerowanie Histogramów dla poszczególnych zmiennych i zapisanie ich do pliku pdf*/
ods pdf file="&wynik\plots.pdf";
	%plot(happy)
	%plot(agea) 
	%plot(gndr)
	%plot(eisced)
	%plot(mnactic)
	%plot(hinctnta)
	%plot(health)
	%plot(rlgdgr)
	%plot(polintr)
	%plot(lrscale)
	%plot(sclmeet)
	%plot(atncrse)
	%plot(ipgdtim)
	%plot(impfree)
	%plot(anvcld)
	%plot(hincfel) 
	%plot(atchctr)
	%plot(evmar)
	%plot(ctzcntr)
	%plot(stfdem)
	%plot(imbgeco)
	%plot(ipudrst)
	%plot(nwspol)
ods pdf close;

/*Makro do generowania tabel kontyngencji*/
%macro table(zmienna);
proc freq data=work.our_noformat;
	tables HPI*&zmienna. / plots=freqplot(twoway=stacked scale=grouppct); 
run;
%mend table;

/*Zbiór zastosowany w tabelach kontyngencji*/
DATA our_noformat;
SET our_noformat;
if happy =<7 then
HPI = "Nieszczesliwy";
if happy >7 then
HPI = "Bardzo Szczesliwy";
RUN;

/*Zapisanie tabel kontyngencji do pliku PDF*/
ods pdf file="&wynik\tables.pdf";
	%table(agea) 
	%table(gndr)
	%table(eisced)
	%table(mnactic)
	%table(hinctnta)
	%table(health)
	%table(rlgdgr)
	%table(polintr)
	%table(lrscale)
	%table(sclmeet)
	%table(atncrse)
	%table(ipgdtim)
	%table(impfree)
	%table(anvcld)
	%table(hincfel) 
	%table(atchctr)
	%table(evmar)
	%table(ctzcntr)
	%table(stfdem)
	%table(imbgeco)
	%table(ipudrst)
	%table(nwspol)
ods pdf close;

/*œrednia, minimalna i maksymalna wartoœci dla zmiennych ci¹g³ych*/
proc means data=our_format_nomiss2 min max mean;
	var agea nwspol;
run;


/*Kategoryzacja zmiennych na podstawie tabel kontyngencji*/
/*jesli wystepuja wartosci dziwne typu 55 lub 88 czy 999 to kodujemy jako missing (.)*/
data work.data_categorization;
	set our_format_nomiss2;

/*zmienna eised*/
	if eisced = 1 
	or eisced=2 

		then eisced_cat=1;

	else if eisced=3
	or eisced=4
		then eisced_cat=2;
	else if eisced=5
	or eisced = 6
		then eisced_cat=3;
	else if eisced=7
	
		then eisced_cat=4;
	else
		eisced_cat=.;

/*zmienna mnactic*/
	if mnactic = 3
	or mnactic = 4
		then mnactic_cat = 3;
	else if  mnactic = 77
	or mnactic = 88
		then mnactic_cat = .;
	else
		mnactic_cat = mnactic;

/*hinctnta*/

	if hinctnta = 1
	or hinctnta = 2 
	or hinctnta = 3 
	or hinctnta = 4
		then hinctnta_cat = 1;
	else if hinctnta = 5
	or hinctnta = 6
	or hinctnta = 7
	then hinctnta_cat = 2;
	else if hinctnta = 8
	or hinctnta = 9 
	or hinctnta = 10
		then hinctnta_cat = 3;
	else 
	hinctnta_cat = .;

/*health*/
	if health = 1 
		then health_cat = 1;
	else if health = 2 
		then health_cat = 2;
	else if health = 3
		then health_cat = 3;
	else if health = 4
	or health = 5
		then health_cat = 4;
	else health_cat = .;
		
/*rlgdgr*/
	if rlgdgr = 0
		then rlgdgr_cat = 1;
	else if rlgdgr = 1 
	or rlgdgr = 2
	or rlgdgr =3
	or rlgdgr = 4
		then rlgdgr_cat = 2;
	else if rlgdgr = 5
	or rlgdgr = 6 
	or rlgdgr = 7
	or rlgdgr = 8
		then rlgdgr_cat = 3;
	else if rlgdgr  = 9
	or rlgdgr = 10 
		then rlgdgr_cat = 4;
	else rlgdgr_cat = .;

/*	polintr*/
	if polintr = 1
	or polintr = 2
		then polintr_cat = 1;
	else if polintr = 3
	or polintr = 4
		then polintr_cat = 2;
	else polintr_cat = .;

/*	lrscale*/
	if lrscale = 0
	or lrscale = 1
	or lrscale = 2
	or lrscale = 3
	or lrscale = 4
		then lrscale_cat = 1;
	else if lrscale = 5
		then lrscale_cat = 2;
	else if lrscale = 6
	or lrscale = 7
	or lrscale = 8
	or lrscale = 9
	or lrscale = 10
		then lrscale_cat = 3;
	else lrscale_cat = .;

/*sclmeet*/
	if sclmeet = 1
	or sclmeet = 2
	or sclmeet = 3
		then sclmeet_cat = 1;
	else if sclmeet = 4
	or sclmeet = 5
		then sclmeet_cat = 2;
	else if sclmeet = 6
	or sclmeet = 7
		then sclmeet_cat = 3;
	else sclmeet_cat = .;

/*ipgdtim*/
	if ipgdtim = 1
	or ipgdtim = 2
		then ipgdtim_cat = 1;
	else if ipgdtim = 3
		then ipgdtim_cat = 2;
	else if ipgdtim = 4
	or ipgdtim = 5
	or ipgdtim = 6
	then ipgdtim_cat = 3;
	else ipgdtim_cat = .;

/*impfree*/
	if impfree = 1
	or impfree = 2
		then impfree_cat = 1;
	else if impfree = 3
		then impfree_cat = 2;
	else if impfree = 4
	or impfree = 5
	or impfree = 6
		then impfree_cat = 3;
	else impfree_cat = .;



/*anvcld*/
	if anvcld = 1 
	or anvcld = 2
		then anvcld_cat =1;
	else if anvcld = 3
	or anvcld = 4
		then anvcld_cat =2;
	else if anvcld = 5 
	or anvcld = 6 
		then anvcld_cat  =3;
	else anvcld_cat = .; 

/*hincfel*/


	if hincfel = 1
		then hincfel_cat = 1;
	else if hincfel = 2
	or hincfel = 3
	then hincfel_cat = 2;
	else if hincfel = 4
	then hincfel_cat = 3;
	else hincfel_cat = .;

/*atchctr*/
	if atchctr = 0
	or atchctr  = 1 
	or atchctr = 2
	or atchctr =3 
	or atchctr =4
	or atchctr = 5
		then atchctr_cat = 1;
	else if atchctr=6
	or atchctr = 7
		then atchctr_cat =2 ;
	else if atchctr = 8
	or atchctr =9
	or atchctr =10
		then atchctr_cat =3 ;
	else atchctr_cat = . ;

/*	stfdem*/
	if stfdem = 0
	or stfdem = 1
	or stfdem =2
	or stfdem =3
	or stfdem = 4
	then stfdem_cat =1;
	else if stfdem = 5
	or stfdem =6 
	or stfdem =7 
	then stfdem_cat = 2;
	else if stfdem =8
	or stfdem = 9 
	or stfdem = 10
	then stfdem_cat = 3;
	else stfdem_cat =.;
	
/*imbgeco*/
	if imbgeco = 0
	or imbgeco =1 
	or imbgeco =2 
	or imbgeco=3
	or imbgeco=4
	then imbgeco_cat = 1;
	else if imbgeco = 5
	or imbgeco =6 
	or imbgeco =7 
	then imbgeco_cat = 2;
	else if imbgeco = 8
	or imbgeco = 9 
	or imbgeco = 10
	then imbgeco_cat = 3;
	else imbgeco_cat = .;


/*ipudrst*/
	if ipudrst =1 
	or ipudrst = 2
	then ipudrst_cat = 1;
	else if ipudrst = 3
	or ipudrst =4 
	then ipudrst_cat = 2;
	else if ipudrst = 5
	or ipudrst = 6
	then ipudrst_cat =3;
	else ipudrst_cat = .;

/*ctzcntr*/
	if ctzcntr = 8
		then ctzcntr_cat = .;
	else ctzcntr_cat = ctzcntr;

/*evmar*/
	if evmar = 7
		then evmar_cat = .;
	else evmar_cat = evmar;

/*atncrse*/
	if atncrse = 8
		then atncrse = .;
	else atncrse_cat = atncrse;


/*gndr - brak dziwnych kategorii*/

/*agea*/
	if agea = 999
		then agea_cat = .;
	else agea_cat = agea;

/*	nwspol*/
	if nwspol = 8888
		then nwspol_cat = .;
	else nwspol_cat = nwspol;
run;

/*Makro generuj¹ce tablice kontyngencji dla zmiennych po kategoryzacji*/
%macro tables_post_cat(zmienna);
proc freq data=work.data_categorization;
tables HPI*&zmienna. / plots=freqplot(twoway=stacked scale=grouppct);
run;
%mend tables_post_cat;

/*wygenerowanie tablic kontyngencji i zapisanie ich do pliku PDF*/
ods pdf file="&wynik\tables_post_cat.pdf";
ods graphics on;
%tables_post_cat(agea_cat) 
%tables_post_cat(gndr)
%tables_post_cat(eisced_cat)
%tables_post_cat(mnactic_cat)
%tables_post_cat(hinctnta_cat)
%tables_post_cat(health_cat)
%tables_post_cat(rlgdgr_cat)
%tables_post_cat(polintr_cat)
%tables_post_cat(lrscale_cat)
%tables_post_cat(sclmeet_cat)
%tables_post_cat(atncrse_cat)
%tables_post_cat(ipgdtim_cat)
%tables_post_cat(impfree_cat)
%tables_post_cat(anvcld_cat)
%tables_post_cat(hincfel_cat) 
%tables_post_cat(atchctr_cat)
%tables_post_cat(evmar_cat)
%tables_post_cat(ctzcntr_cat)
%tables_post_cat(stfdem_cat)
%tables_post_cat(imbgeco_cat)
%tables_post_cat(ipudrst_cat)
%tables_post_cat(nwspol_cat)
ods graphics off;
ods pdf close;

/*Makro do wygenerowania wykresów po kategoryzacji*/
%macro plot_post_cat(zmienna);
	title "Histogram zmiennej: &zmienna.";
	proc sgplot data=work.data_categorization;
		vbar &zmienna. / group=HPI;
	styleattrs datacolors=( red lightgreen);
	run;
	title;
%mend plot_post_cat;

/*Wygenerowanie wykresów i zapisanie ich do pliku PDF*/
ods pdf file="&wynik\plots_post_cat.pdf";
ods graphics on;
%plot_post_cat(HPI) 
%plot_post_cat(agea_cat) 
%plot_post_cat(gndr)
%plot_post_cat(eisced_cat)
%plot_post_cat(mnactic_cat)
%plot_post_cat(hinctnta_cat)
%plot_post_cat(health_cat)
%plot_post_cat(rlgdgr_cat)
%plot_post_cat(polintr_cat)
%plot_post_cat(lrscale_cat)
%plot_post_cat(sclmeet_cat)
%plot_post_cat(atncrse_cat)
%plot_post_cat(ipgdtim_cat)
%plot_post_cat(impfree_cat)
%plot_post_cat(anvcld_cat)
%plot_post_cat(hincfel_cat) 
%plot_post_cat(atchctr_cat)
%plot_post_cat(evmar_cat)
%plot_post_cat(ctzcntr_cat)
%plot_post_cat(stfdem_cat)
%plot_post_cat(imbgeco_cat)
%plot_post_cat(ipudrst_cat)
%plot_post_cat(nwspol_cat)
ods graphics off;
ods pdf close;

/*Makro do oceny istotnoœci wybranych zmiennych*/
%macro selection(zmienna);
proc freq data=work.data_categorization;
 tables HPI*&zmienna. / chisq;
run;
%mend selection;

/*Wygenerowanie wyników na podstawie powy¿szego makra*/
%selection(agea_cat) 
%selection(gndr)
%selection(eisced_cat)
%selection(mnactic_cat)
%selection(hinctnta_cat)
%selection(health_cat)
%selection(rlgdgr_cat)
%selection(polintr_cat)
%selection(lrscale_cat)
%selection(sclmeet_cat)
%selection(atncrse_cat)
%selection(ipgdtim_cat)
%selection(impfree_cat)
%selection(anvcld_cat)
%selection(hincfel_cat) 
%selection(atchctr_cat)
%selection(evmar_cat)
%selection(ctzcntr_cat)
%selection(stfdem_cat)
%selection(imbgeco_cat)
%selection(ipudrst_cat)
%selection(nwspol_cat)

/*Wygenerowanie statystyk dla zmiennych ci¹g³ych*/

proc univariate data=work.data_categorization;
var nwspol;
run;

proc means data=work.data_categorization;
var nwspol;
run;


proc univariate data=work.data_categorization;
var nwspol_cat;
run;

proc means data=work.data_categorization;
var nwspol_cat;
run;

proc univariate data=work.data_categorization;
var agea;
run;

proc means data=work.data_categorization;
var agea;
run;


proc univariate data=work.data_categorization;
var agea_cat;
run;

proc means data=work.data_categorization;
var agea_cat;
run;

/*WYNIKI dla zmiennych*/

/*agea - nieistotne*/
/*gndr - nieistotne*/
/*eisced_cat - istotne*/
/*mnactic_cat - istotne*/
/*hinstnta_cat - istotne*/
/*health_cat - istotne*/
/*rlgdgr_cat - nieistotne*/
/*polintr_cat - nieistotne*/
/*lrscale_cat - istotne*/
/*sclmeet_cat - istotne*/
/*atncrse_cat - istotna*/
/*ipgdtim_cat - istotna*/
/*impfree_cat - nieistotna*/
/*anvcld_cat - istotna*/
/*hincfel_cat - istotna*/
/*atchctr_cat - istotna*/
/*evmar_cat - istotna*/
/*ctzcntr_cat - istotna]\*/
/*stfdem_cat - istotna*/
/*inbgeco_cat - istotna*/
/*iupdrst_cat - niesitotne*/
/*nwspol - nieistotna*/

/*HIPOTEZY*/
/*zmienne g³ównego zainteresowania - health_cat - im ludzie zdrowsi tym szczêsliwsi*/
/*sclmeet_cat - im bardziej spo³eczni (w sensie spotkañ ze znajomymi) tym szczêsliwsi*/
/*stfdem - im bardziej zadowolony z demokracji - tym szczesliwszy*/

/*agea - nieistotne p-value 0.38 */
/*gndr - nieistotne p-value 0.59*/
/*rlgdgr_cat - nieistotne p-value 0.68*/
/*polintr_cat - nieistotne p-value 0.39*/
/*impfree_cat - nieistotna p-value 0.53*/
/*iupdrst_cat - niesitotne p-value 0.13*/
/*nwspol - nieistotna p-value 0.14*/

/*1 etap*/

/*statystyki tol i vif - proc reg, poniewaz nie dzialaja te opcje w proc logistic*/
proc reg data=work.data_categorization plots=ALL;
model HPI = health_cat sclmeet_cat stfdem_cat gndr agea_cat eisced_cat mnactic_cat hinctnta_cat rlgdgr_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat impfree_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat nwspol_cat / tol vif;
run;


/*model dla wszystkich zmiennych*/
proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat rlgdgr_cat  polintr_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat impfree_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat ipudrst_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat gndr agea_cat eisced_cat mnactic_cat hinctnta_cat rlgdgr_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat impfree_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat nwspol_cat;
run;

/*Wyrzucamy z modelu zmienne z p-value > 0.05, od najwiêkszego p-value do najmniejszego*/

/*Wyrzucamy zmienna z najwiekszym p-value - rlgdgr_cat*/
proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat  polintr_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat impfree_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat ipudrst_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat gndr agea_cat eisced_cat mnactic_cat hinctnta_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat impfree_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat nwspol_cat;
run;

/*po wyrzuceniue rlgdgr_cat oszacowania paramterów przy zmiennych g³ównego zainteresowania nie zmieni³y siê - wyrzucamy*/

/*Wyrzucamy zmienna z 2 najwiekszym - p-value - gndr*/
proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat  polintr_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat impfree_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat ipudrst_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat agea_cat eisced_cat mnactic_cat hinctnta_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat impfree_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat nwspol_cat;
run;

/*po wyrzuceniue gndr oszacowania paramterów przy zmiennych g³ównego zaintereswoania nie zmieni³y siê - wyrzucamy*/

/*Wyrzucamy zmienna z 3 najwiekszym - p-value - impfree_cat*/

proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat  polintr_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat ipudrst_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat agea_cat eisced_cat mnactic_cat hinctnta_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat nwspol_cat;
run;

/*po wyrzuceniue impfree_cat oszacowania paramterów przy zmiennych g³ównego zainteresowania nie zmieni³y siê - wyrzucamy*/

/*Wyrzucamy zmienna z 4 najwiekszym - p-value - polintr_cat*/

proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat ipudrst_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat agea_cat eisced_cat mnactic_cat hinctnta_cat lrscale_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat nwspol_cat;
run;

/*Oszacowanie parametru przy zmiennej health_cat = 3 po usunieciu polintr_cat zmienia siê o 12% - traktujemy jako zmienna zak³ócaj¹c¹ i nie wyrzucamy z modelu*/

/*Wyrzucamy zmienna z 5 najwiekszym - p-value - agea_cat*/

proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat  polintr_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat ipudrst_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat eisced_cat mnactic_cat hinctnta_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat nwspol_cat;
run;

/*po wyrzuceniue agea_cat oszacowania paramterów przy zmiennych g³ównego zaintereswoania nie zmieni³y siê - wyrzucamy*/

/*Wyrzucamy zmienna z 6 najwiekszym - p-value - nwspol_cat*/

proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat  polintr_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat ipudrst_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat eisced_cat mnactic_cat hinctnta_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat;
run;

/*po wyrzuceniue nwspol_cat oszacowania paramterów przy zmiennych g³ównego zaintereswoania nie zmieni³y siê - wyrzucamy*/

/*Wyrzucamy zmienna z 7 najwiekszym - p-value - ipudrst_cat*/

proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat  polintr_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat eisced_cat mnactic_cat hinctnta_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat;
run;

/*Oszacowanie parametru przy zmiennej health_cat = 3 po usunieciu ipudrst_cat zmienia siê o 12% - traktujemy jako zmienna zak³ócaj¹c¹ i nie wyrzucamy z modelu*/


/*finalnie w 1 etapie otrzymujemy poni¿szy model - 2 zmienne traktujemy jako zmienne zak³ócaj¹ce - ipudrst_cat, polintr_cat*/
proc logistic data=work.data_categorization plots=ALL;
class eisced_cat mnactic_cat hinctnta_cat health_cat  polintr_cat lrscale_cat sclmeet_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat stfdem_cat imbgeco_cat ipudrst_cat/ param=ref;
model HPI(event="1")= health_cat sclmeet_cat stfdem_cat eisced_cat mnactic_cat hinctnta_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat;
run;


/*Zbiór tylko z pokategoryzowanymi zmiennymi */
data work.data_categorization_2;
set work.data_categorization;
keep HPI health_cat sclmeet_cat stfdem_cat gndr agea_cat eisced_cat mnactic_cat hinctnta_cat rlgdgr_cat  polintr_cat lrscale_cat atncrse_cat
ipgdtim_cat impfree_cat anvcld_cat hincfel_cat atchctr_cat evmar_cat ctzcntr_cat imbgeco_cat ipudrst_cat nwspol_cat;
run;


/*etap 2*/
/*model z interakcjami - metoda stepwise*/

PROC LOGISTIC DATA=work.data_categorization_2
		PLOTS(ONLY)=ALL
	;
	CLASS gndr 	(PARAM=REF) eisced_cat 	(PARAM=REF) mnactic_cat 	(PARAM=REF) hinctnta_cat 	(PARAM=REF) health_cat 	(PARAM=REF) rlgdgr_cat 	(PARAM=REF) polintr_cat 	(PARAM=REF) lrscale_cat 	(PARAM=REF) sclmeet_cat 	(PARAM=REF)
	  ipgdtim_cat 	(PARAM=REF) impfree_cat 	(PARAM=REF) anvcld_cat 	(PARAM=REF) hincfel_cat 	(PARAM=REF) atchctr_cat 	(PARAM=REF) stfdem_cat 	(PARAM=REF) imbgeco_cat 	(PARAM=REF) ipudrst_cat 	(PARAM=REF)
	  ctzcntr_cat 	(PARAM=REF) evmar_cat 	(PARAM=REF) atncrse_cat 	(PARAM=REF);
	MODEL HPI (Event = '1')=agea_cat nwspol_cat gndr eisced_cat mnactic_cat hinctnta_cat health_cat rlgdgr_cat polintr_cat lrscale_cat sclmeet_cat ipgdtim_cat
impfree_cat anvcld_cat hincfel_cat atchctr_cat stfdem_cat imbgeco_cat ipudrst_cat ctzcntr_cat evmar_cat atncrse_cat agea_cat*nwspol_cat agea_cat*gndr
agea_cat*eisced_cat agea_cat*mnactic_cat agea_cat*hinctnta_cat agea_cat*health_cat agea_cat*rlgdgr_cat agea_cat*polintr_cat agea_cat*lrscale_cat
agea_cat*sclmeet_cat agea_cat*ipgdtim_cat agea_cat*impfree_cat agea_cat*anvcld_cat agea_cat*hincfel_cat agea_cat*atchctr_cat agea_cat*stfdem_cat
agea_cat*imbgeco_cat agea_cat*ipudrst_cat agea_cat*ctzcntr_cat agea_cat*evmar_cat agea_cat*atncrse_cat nwspol_cat*gndr nwspol_cat*eisced_cat
nwspol_cat*mnactic_cat nwspol_cat*hinctnta_cat nwspol_cat*health_cat nwspol_cat*rlgdgr_cat nwspol_cat*polintr_cat nwspol_cat*lrscale_cat nwspol_cat*sclmeet_cat
nwspol_cat*ipgdtim_cat nwspol_cat*impfree_cat nwspol_cat*anvcld_cat nwspol_cat*hincfel_cat nwspol_cat*atchctr_cat nwspol_cat*stfdem_cat nwspol_cat*imbgeco_cat
nwspol_cat*ipudrst_cat nwspol_cat*ctzcntr_cat nwspol_cat*evmar_cat nwspol_cat*atncrse_cat gndr*eisced_cat gndr*mnactic_cat gndr*hinctnta_cat gndr*health_cat
gndr*rlgdgr_cat gndr*polintr_cat gndr*lrscale_cat gndr*sclmeet_cat gndr*ipgdtim_cat gndr*impfree_cat gndr*anvcld_cat gndr*hincfel_cat gndr*atchctr_cat
gndr*stfdem_cat gndr*imbgeco_cat gndr*ipudrst_cat gndr*ctzcntr_cat gndr*evmar_cat gndr*atncrse_cat eisced_cat*mnactic_cat eisced_cat*hinctnta_cat
eisced_cat*health_cat eisced_cat*rlgdgr_cat eisced_cat*polintr_cat eisced_cat*lrscale_cat eisced_cat*sclmeet_cat eisced_cat*ipgdtim_cat eisced_cat*impfree_cat
eisced_cat*anvcld_cat eisced_cat*hincfel_cat eisced_cat*atchctr_cat eisced_cat*stfdem_cat eisced_cat*imbgeco_cat eisced_cat*ipudrst_cat eisced_cat*ctzcntr_cat
eisced_cat*evmar_cat eisced_cat*atncrse_cat mnactic_cat*hinctnta_cat mnactic_cat*health_cat mnactic_cat*rlgdgr_cat mnactic_cat*polintr_cat mnactic_cat*lrscale_cat
mnactic_cat*sclmeet_cat mnactic_cat*ipgdtim_cat mnactic_cat*impfree_cat mnactic_cat*anvcld_cat mnactic_cat*hincfel_cat mnactic_cat*atchctr_cat mnactic_cat*stfdem_cat
mnactic_cat*imbgeco_cat mnactic_cat*ipudrst_cat mnactic_cat*ctzcntr_cat mnactic_cat*evmar_cat mnactic_cat*atncrse_cat hinctnta_cat*health_cat hinctnta_cat*rlgdgr_cat
hinctnta_cat*polintr_cat hinctnta_cat*lrscale_cat hinctnta_cat*sclmeet_cat hinctnta_cat*ipgdtim_cat hinctnta_cat*impfree_cat hinctnta_cat*anvcld_cat
hinctnta_cat*hincfel_cat hinctnta_cat*atchctr_cat hinctnta_cat*stfdem_cat hinctnta_cat*imbgeco_cat hinctnta_cat*ipudrst_cat hinctnta_cat*ctzcntr_cat
hinctnta_cat*evmar_cat hinctnta_cat*atncrse_cat health_cat*rlgdgr_cat health_cat*polintr_cat health_cat*lrscale_cat health_cat*sclmeet_cat health_cat*ipgdtim_cat
health_cat*impfree_cat health_cat*anvcld_cat health_cat*hincfel_cat health_cat*atchctr_cat health_cat*stfdem_cat health_cat*imbgeco_cat health_cat*ipudrst_cat
health_cat*ctzcntr_cat health_cat*evmar_cat health_cat*atncrse_cat rlgdgr_cat*polintr_cat rlgdgr_cat*lrscale_cat rlgdgr_cat*sclmeet_cat rlgdgr_cat*ipgdtim_cat
rlgdgr_cat*impfree_cat rlgdgr_cat*anvcld_cat rlgdgr_cat*hincfel_cat rlgdgr_cat*atchctr_cat rlgdgr_cat*stfdem_cat rlgdgr_cat*imbgeco_cat rlgdgr_cat*ipudrst_cat
rlgdgr_cat*ctzcntr_cat rlgdgr_cat*evmar_cat rlgdgr_cat*atncrse_cat polintr_cat*lrscale_cat polintr_cat*sclmeet_cat polintr_cat*ipgdtim_cat polintr_cat*impfree_cat
polintr_cat*anvcld_cat polintr_cat*hincfel_cat polintr_cat*atchctr_cat polintr_cat*stfdem_cat polintr_cat*imbgeco_cat polintr_cat*ipudrst_cat polintr_cat*ctzcntr_cat
polintr_cat*evmar_cat polintr_cat*atncrse_cat lrscale_cat*sclmeet_cat lrscale_cat*ipgdtim_cat lrscale_cat*impfree_cat lrscale_cat*anvcld_cat lrscale_cat*hincfel_cat
lrscale_cat*atchctr_cat lrscale_cat*stfdem_cat lrscale_cat*imbgeco_cat lrscale_cat*ipudrst_cat lrscale_cat*ctzcntr_cat lrscale_cat*evmar_cat lrscale_cat*atncrse_cat
sclmeet_cat*ipgdtim_cat sclmeet_cat*impfree_cat sclmeet_cat*anvcld_cat sclmeet_cat*hincfel_cat sclmeet_cat*atchctr_cat sclmeet_cat*stfdem_cat sclmeet_cat*imbgeco_cat
sclmeet_cat*ipudrst_cat sclmeet_cat*ctzcntr_cat sclmeet_cat*evmar_cat sclmeet_cat*atncrse_cat ipgdtim_cat*impfree_cat ipgdtim_cat*anvcld_cat ipgdtim_cat*hincfel_cat
ipgdtim_cat*atchctr_cat ipgdtim_cat*stfdem_cat ipgdtim_cat*imbgeco_cat ipgdtim_cat*ipudrst_cat ipgdtim_cat*ctzcntr_cat ipgdtim_cat*evmar_cat ipgdtim_cat*atncrse_cat
impfree_cat*anvcld_cat impfree_cat*hincfel_cat impfree_cat*atchctr_cat impfree_cat*stfdem_cat impfree_cat*imbgeco_cat impfree_cat*ipudrst_cat impfree_cat*ctzcntr_cat 
impfree_cat*evmar_cat impfree_cat*atncrse_cat anvcld_cat*hincfel_cat anvcld_cat*atchctr_cat anvcld_cat*stfdem_cat anvcld_cat*imbgeco_cat anvcld_cat*ipudrst_cat
anvcld_cat*ctzcntr_cat anvcld_cat*evmar_cat anvcld_cat*atncrse_cat hincfel_cat*atchctr_cat hincfel_cat*stfdem_cat hincfel_cat*imbgeco_cat hincfel_cat*ipudrst_cat
hincfel_cat*ctzcntr_cat hincfel_cat*evmar_cat hincfel_cat*atncrse_cat atchctr_cat*stfdem_cat atchctr_cat*imbgeco_cat atchctr_cat*ipudrst_cat atchctr_cat*ctzcntr_cat
atchctr_cat*evmar_cat atchctr_cat*atncrse_cat stfdem_cat*imbgeco_cat stfdem_cat*ipudrst_cat stfdem_cat*ctzcntr_cat stfdem_cat*evmar_cat stfdem_cat*atncrse_cat
imbgeco_cat*ipudrst_cat imbgeco_cat*ctzcntr_cat imbgeco_cat*evmar_cat imbgeco_cat*atncrse_cat ipudrst_cat*ctzcntr_cat ipudrst_cat*evmar_cat ipudrst_cat*atncrse_cat
ctzcntr_cat*evmar_cat ctzcntr_cat*atncrse_cat evmar_cat*atncrse_cat		/
		SELECTION=STEPWISE
		SLE=0.05
		SLS=0.05
		LINK=LOGIT
		CLPARM=WALD
		ALPHA=0.05
	;
RUN;


/*model z interakcjami - metoda forward*/
PROC LOGISTIC DATA=work.data_categorization_2
		PLOTS(ONLY)=ALL
	;
	CLASS gndr 	(PARAM=REF) eisced_cat 	(PARAM=REF) mnactic_cat 	(PARAM=REF) hinctnta_cat 	(PARAM=REF) health_cat 	(PARAM=REF) rlgdgr_cat 	(PARAM=REF) polintr_cat 	(PARAM=REF) lrscale_cat 	(PARAM=REF) sclmeet_cat 	(PARAM=REF)
	  ipgdtim_cat 	(PARAM=REF) impfree_cat 	(PARAM=REF) anvcld_cat 	(PARAM=REF) hincfel_cat 	(PARAM=REF) atchctr_cat 	(PARAM=REF) stfdem_cat 	(PARAM=REF) imbgeco_cat 	(PARAM=REF) ipudrst_cat 	(PARAM=REF)
	  ctzcntr_cat 	(PARAM=REF) evmar_cat 	(PARAM=REF) atncrse_cat 	(PARAM=REF);
	MODEL HPI (Event = '1')=agea_cat nwspol_cat gndr eisced_cat mnactic_cat hinctnta_cat health_cat rlgdgr_cat polintr_cat lrscale_cat sclmeet_cat ipgdtim_cat 
impfree_cat anvcld_cat hincfel_cat atchctr_cat stfdem_cat imbgeco_cat ipudrst_cat ctzcntr_cat evmar_cat atncrse_cat agea_cat*nwspol_cat agea_cat*gndr 
agea_cat*eisced_cat agea_cat*mnactic_cat agea_cat*hinctnta_cat agea_cat*health_cat agea_cat*rlgdgr_cat agea_cat*polintr_cat agea_cat*lrscale_cat 
agea_cat*sclmeet_cat agea_cat*ipgdtim_cat agea_cat*impfree_cat agea_cat*anvcld_cat agea_cat*hincfel_cat agea_cat*atchctr_cat agea_cat*stfdem_cat 
agea_cat*imbgeco_cat agea_cat*ipudrst_cat agea_cat*ctzcntr_cat agea_cat*evmar_cat agea_cat*atncrse_cat nwspol_cat*gndr nwspol_cat*eisced_cat nwspol_cat*mnactic_cat 
nwspol_cat*hinctnta_cat nwspol_cat*health_cat nwspol_cat*rlgdgr_cat nwspol_cat*polintr_cat nwspol_cat*lrscale_cat nwspol_cat*sclmeet_cat nwspol_cat*ipgdtim_cat 
nwspol_cat*impfree_cat nwspol_cat*anvcld_cat nwspol_cat*hincfel_cat nwspol_cat*atchctr_cat nwspol_cat*stfdem_cat nwspol_cat*imbgeco_cat nwspol_cat*ipudrst_cat 
nwspol_cat*ctzcntr_cat nwspol_cat*evmar_cat nwspol_cat*atncrse_cat gndr*eisced_cat gndr*mnactic_cat gndr*hinctnta_cat gndr*health_cat gndr*rlgdgr_cat 
gndr*polintr_cat gndr*lrscale_cat gndr*sclmeet_cat gndr*ipgdtim_cat gndr*impfree_cat gndr*anvcld_cat gndr*hincfel_cat gndr*atchctr_cat gndr*stfdem_cat 
gndr*imbgeco_cat gndr*ipudrst_cat gndr*ctzcntr_cat gndr*evmar_cat gndr*atncrse_cat eisced_cat*mnactic_cat eisced_cat*hinctnta_cat eisced_cat*health_cat 
eisced_cat*rlgdgr_cat eisced_cat*polintr_cat eisced_cat*lrscale_cat eisced_cat*sclmeet_cat eisced_cat*ipgdtim_cat eisced_cat*impfree_cat eisced_cat*anvcld_cat 
eisced_cat*hincfel_cat eisced_cat*atchctr_cat eisced_cat*stfdem_cat eisced_cat*imbgeco_cat eisced_cat*ipudrst_cat eisced_cat*ctzcntr_cat eisced_cat*evmar_cat
eisced_cat*atncrse_cat mnactic_cat*hinctnta_cat mnactic_cat*health_cat mnactic_cat*rlgdgr_cat mnactic_cat*polintr_cat mnactic_cat*lrscale_cat mnactic_cat*sclmeet_cat
mnactic_cat*ipgdtim_cat mnactic_cat*impfree_cat mnactic_cat*anvcld_cat mnactic_cat*hincfel_cat mnactic_cat*atchctr_cat mnactic_cat*stfdem_cat mnactic_cat*imbgeco_cat
mnactic_cat*ipudrst_cat mnactic_cat*ctzcntr_cat mnactic_cat*evmar_cat mnactic_cat*atncrse_cat hinctnta_cat*health_cat hinctnta_cat*rlgdgr_cat 
hinctnta_cat*polintr_cat hinctnta_cat*lrscale_cat hinctnta_cat*sclmeet_cat hinctnta_cat*ipgdtim_cat hinctnta_cat*impfree_cat hinctnta_cat*anvcld_cat 
hinctnta_cat*hincfel_cat hinctnta_cat*atchctr_cat hinctnta_cat*stfdem_cat hinctnta_cat*imbgeco_cat hinctnta_cat*ipudrst_cat hinctnta_cat*ctzcntr_cat 
hinctnta_cat*evmar_cat hinctnta_cat*atncrse_cat health_cat*rlgdgr_cat health_cat*polintr_cat health_cat*lrscale_cat health_cat*sclmeet_cat health_cat*ipgdtim_cat 
health_cat*impfree_cat health_cat*anvcld_cat health_cat*hincfel_cat health_cat*atchctr_cat health_cat*stfdem_cat health_cat*imbgeco_cat health_cat*ipudrst_cat 
health_cat*ctzcntr_cat health_cat*evmar_cat health_cat*atncrse_cat rlgdgr_cat*polintr_cat rlgdgr_cat*lrscale_cat rlgdgr_cat*sclmeet_cat rlgdgr_cat*ipgdtim_cat 
rlgdgr_cat*impfree_cat rlgdgr_cat*anvcld_cat rlgdgr_cat*hincfel_cat rlgdgr_cat*atchctr_cat rlgdgr_cat*stfdem_cat rlgdgr_cat*imbgeco_cat rlgdgr_cat*ipudrst_cat 
rlgdgr_cat*ctzcntr_cat rlgdgr_cat*evmar_cat rlgdgr_cat*atncrse_cat polintr_cat*lrscale_cat polintr_cat*sclmeet_cat polintr_cat*ipgdtim_cat polintr_cat*impfree_cat
polintr_cat*anvcld_cat polintr_cat*hincfel_cat polintr_cat*atchctr_cat polintr_cat*stfdem_cat polintr_cat*imbgeco_cat polintr_cat*ipudrst_cat polintr_cat*ctzcntr_cat
polintr_cat*evmar_cat polintr_cat*atncrse_cat lrscale_cat*sclmeet_cat lrscale_cat*ipgdtim_cat lrscale_cat*impfree_cat lrscale_cat*anvcld_cat lrscale_cat*hincfel_cat
lrscale_cat*atchctr_cat lrscale_cat*stfdem_cat lrscale_cat*imbgeco_cat lrscale_cat*ipudrst_cat lrscale_cat*ctzcntr_cat lrscale_cat*evmar_cat lrscale_cat*atncrse_cat
sclmeet_cat*ipgdtim_cat sclmeet_cat*impfree_cat sclmeet_cat*anvcld_cat sclmeet_cat*hincfel_cat sclmeet_cat*atchctr_cat sclmeet_cat*stfdem_cat sclmeet_cat*imbgeco_cat
sclmeet_cat*ipudrst_cat sclmeet_cat*ctzcntr_cat sclmeet_cat*evmar_cat sclmeet_cat*atncrse_cat ipgdtim_cat*impfree_cat ipgdtim_cat*anvcld_cat ipgdtim_cat*hincfel_cat
ipgdtim_cat*atchctr_cat ipgdtim_cat*stfdem_cat ipgdtim_cat*imbgeco_cat ipgdtim_cat*ipudrst_cat ipgdtim_cat*ctzcntr_cat ipgdtim_cat*evmar_cat ipgdtim_cat*atncrse_cat
impfree_cat*anvcld_cat impfree_cat*hincfel_cat impfree_cat*atchctr_cat impfree_cat*stfdem_cat impfree_cat*imbgeco_cat impfree_cat*ipudrst_cat impfree_cat*ctzcntr_cat
impfree_cat*evmar_cat impfree_cat*atncrse_cat anvcld_cat*hincfel_cat anvcld_cat*atchctr_cat anvcld_cat*stfdem_cat anvcld_cat*imbgeco_cat anvcld_cat*ipudrst_cat 
anvcld_cat*ctzcntr_cat anvcld_cat*evmar_cat anvcld_cat*atncrse_cat hincfel_cat*atchctr_cat hincfel_cat*stfdem_cat hincfel_cat*imbgeco_cat hincfel_cat*ipudrst_cat 
hincfel_cat*ctzcntr_cat hincfel_cat*evmar_cat hincfel_cat*atncrse_cat atchctr_cat*stfdem_cat atchctr_cat*imbgeco_cat atchctr_cat*ipudrst_cat atchctr_cat*ctzcntr_cat 
atchctr_cat*evmar_cat atchctr_cat*atncrse_cat stfdem_cat*imbgeco_cat stfdem_cat*ipudrst_cat stfdem_cat*ctzcntr_cat stfdem_cat*evmar_cat stfdem_cat*atncrse_cat 
imbgeco_cat*ipudrst_cat imbgeco_cat*ctzcntr_cat imbgeco_cat*evmar_cat imbgeco_cat*atncrse_cat ipudrst_cat*ctzcntr_cat ipudrst_cat*evmar_cat ipudrst_cat*atncrse_cat
ctzcntr_cat*evmar_cat ctzcntr_cat*atncrse_cat evmar_cat*atncrse_cat		/
		SELECTION=FORWARD
		SLE=0.05
		SLS=0.05
		LINK=LOGIT
		CLPARM=WALD
		ALPHA=0.05
		
	;
RUN;

/*Wyszlo ze istotna interakcja to mnactic_cat*hinctnta_cat*/
/*Zmienne zak³ócaj¹ce uzyskanie w etapie 1: ipudrst_cat, polintr_cat*/
/*gndr wg literatury itotny dla szczescia wiec zostawiamy w finalnym modelu*/


/*Etap 3*/
/*Budujemy model bez zmiennych agea_cat i nwspol_cat rlgdgr_cat i impfree_cat metoda backward*/
/*Inlcude 6 - wymuszamy zmienne g³ównego zainteresowania i zmienne zak³ócaj¹ce i gndr*/
ods graphics on;
PROC LOGISTIC DATA=work.data_categorization_2
		PLOTS(ONLY)=ALL
	;
	CLASS gndr 	(PARAM=REF) eisced_cat (PARAM=REF) mnactic_cat 	(PARAM=REF) hinctnta_cat 	(PARAM=REF) health_cat 	(PARAM=REF) polintr_cat 	(PARAM=REF) lrscale_cat 	(PARAM=REF) sclmeet_cat 	(PARAM=REF) ipgdtim_cat 	(PARAM=REF)
	  anvcld_cat 	(PARAM=REF) hincfel_cat 	(PARAM=REF) atchctr_cat 	(PARAM=REF) stfdem_cat 	(PARAM=REF) imbgeco_cat 	(PARAM=REF) ipudrst_cat 	(PARAM=REF) ctzcntr_cat 	(PARAM=REF) evmar_cat 	(PARAM=REF) atncrse_cat 	(PARAM=REF);
	MODEL HPI (Event = '1')=health_cat sclmeet_cat stfdem_cat polintr_cat ipudrst_cat gndr mnactic_cat hinctnta_cat mnactic_cat*hinctnta_cat eisced_cat  lrscale_cat ipgdtim_cat anvcld_cat
hincfel_cat atchctr_cat  imbgeco_cat ctzcntr_cat evmar_cat atncrse_cat rlgdgr_cat impfree_cat	/
		SELECTION=BACKWARD
		Include=6
		SLS=0.05
		LINK=LOGIT
		CLPARM=WALD
		ALPHA=0.05
		AGGREGATE
		LACKFIT
		SCALE=NONE
	;
RUN;
ods graphics off;

/*model dla wszytskich wybranych zmiennych bez backworda*/
ods graphics on;
PROC LOGISTIC DATA=work.data_categorization_2
		PLOTS=ALL
	;
	CLASS gndr 	(PARAM=REF) eisced_cat (PARAM=REF) mnactic_cat 	(PARAM=REF) hinctnta_cat 	(PARAM=REF) health_cat 	(PARAM=REF) polintr_cat 	(PARAM=REF) lrscale_cat 	(PARAM=REF) sclmeet_cat 	(PARAM=REF) ipgdtim_cat 	(PARAM=REF)
	  anvcld_cat 	(PARAM=REF) hincfel_cat 	(PARAM=REF) atchctr_cat 	(PARAM=REF) stfdem_cat 	(PARAM=REF) imbgeco_cat 	(PARAM=REF) ipudrst_cat 	(PARAM=REF) ctzcntr_cat 	(PARAM=REF) evmar_cat 	(PARAM=REF) atncrse_cat 	(PARAM=REF);
	MODEL HPI (Event = '1')=health_cat sclmeet_cat stfdem_cat polintr_cat ipudrst_cat gndr mnactic_cat hinctnta_cat mnactic_cat*hinctnta_cat eisced_cat  lrscale_cat ipgdtim_cat anvcld_cat
hincfel_cat atchctr_cat  imbgeco_cat ctzcntr_cat evmar_cat atncrse_cat rlgdgr_cat impfree_cat	/
		Include=6
		SLS=0.05
		LINK=LOGIT
		CLPARM=WALD
		ALPHA=0.05
	;
RUN;
ods graphics off;