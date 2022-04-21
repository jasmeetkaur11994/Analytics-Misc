
/** Assigning library reference **/

libname mylib '/home/u59415958/BAN110';

/** Loading data **/

options validvarname=v7;
proc import
datafile= '/home/u59415958/BAN110/suicide_revised.xlsx'
out=mylib.suicide (rename = (VAR11=gdp_per_capita suicides_100k_pop=suicides_100k VAR10=gdp_for_year))
dbms=xlsx 
replace;
getnames=yes;
DBDSOPTS= "DBTYPE=(HDI_for_year='NUM(8)')";
run;

title"Listing first five observations of Suicide Dataset";
proc print data=mylib.suicide (obs=5);
run;

title;
proc contents data=mylib.suicide;


/** Dataset Charecterstics **/

/** 1. Categorical Variables **/

*If categorical, show the frequency distribution of each of the possible values. 
Interpret. Is the dataset balanced? Any other comment? *;

* age, sex, country, country_year, Generation*;
* we have sorted the data where the observations with the highest frequency will be displayed first*;
 
title "examine the variables";
proc freq data=mylib.suicide order=freq;
tables age sex country country_year generation / nocum;
run;

proc freq data=mylib.suicide;
tables age*sex / list;
run;

proc freq data=mylib.suicide;
tables country*country_year*generation / list;
run;

* Tabular listing for categorical variables*;

proc tabulate data=mylib.suicide format=6.;
class age sex; 
tables age all, sex all / rts=15; 
keylabel n=' ' all = 'Total';
run;

proc tabulate data=mylib.suicide format=6.;
class country generation; 
tables country all,generation all / rts=15; 
keylabel n=' ' all = 'Total';
run;

 *We can observe that men and women were both eqaul in the number of suicides, even when including their age,
 suicides are distributed unequally with Austria being highest and Mongolia the lowest*;

* There are a few missing values in the dataset*;
/** 2. Numerical Target Variables **/

ods trace on;
title "Running PROC UNIVARIATE on numeric target variables ";
ODS Select ExtremeObs Quantiles Histogram;
proc univariate data = mylib.suicide nextrobs=10;
   var suicides_no suicides_100k;
   histogram / normal;
run;
ods trace off;

title "proc means to list the target numerical attributes & their descriptive statistics of suicide dataset";
proc means data = mylib.suicide n nmiss mean min max stddev maxdec=3;
   var suicides_no suicides_100k;
run;

/**** ANALYSIS OF CATEGORICAL VARIABLES *****/

/** checking and correcting errors **/

title "Identifying Data Errors-Sex";
proc print data=mylib.suicide;
var sex;
where sex not in ("female", "male");
run;

title "Identifying Data Errors-Generation";
proc print data=mylib.suicide;
var generation;
where generation not in ("Generation Z", "Generation X", "Silent", "Boomers", "Millenials", "G.I. Generation");
run;

title "Correcting Errors-Sex";
proc format;
value $gender 'f'='female' 'm'='male';
run;

data temp;
set mylib.suicide;
format sex $gender.;
run;

title "Correcting Errors-Generation";
proc format;
value $gen 'X'= 'Generation X' 'G.I.'='G.I. Generation';
run;

data temp;
set mylib.suicide;
format generation $gen.;
run;

proc print data=temp (obs=20);
run;


/*Finding Missing Values-*/

data mylib.suicide_missing;
set mylib.suicide(keep= age sex country country_year Generation);
missingCheck = CMISS(of _all_)-1;
run;

title"Listing missing values";
proc print data=mylib.suicide_missing(obs=20);
var country sex age country_year generation missingcheck;
run;

/* Treating Missing Values */

data mylib.suicide_missing;
set mylib.suicide;
if missing(age) then do age="NA";
end;
if missing(generation) then do generation="NA";
end;
if missing(sex) then do sex="NA";
end;
if missing(country) then do country="NA";
end;
if missing(country_year) then do country_year="NA";
end;
run;

title"Listing dataset after treating missing values";
proc print data=mylib.suicide_missing(obs=20);
var country sex age country_year generation ;
run;

/* Creating Derived variable */

/*  Deriving Variable Gender
we create a new data set nos where we will modify the data set extracted from the csv file
We will create a new variable named gender with values M and F to replace sex variable from the datase.
This is done to make the table simple and easy to understand.
We will use if and else if statement to change the values in the sex table with the desired ones.
In the end we will use drop to remove the sex variable from the new dataset created.
*/

data mylib.nos;
set mylib.suicide;
if sex= 'male' then gender = "M";
else if sex= 'female' then gender='F';
drop sex;
run;


proc freq data = mylib.nos;
table gender;

/*grouping categorical variable (combining values) 
We will create a new dataset grouping multiple age groups in a narrower range to simplify the data. 
We will create a new dataset named nos8 and use set to take data from dataset extracted from the csv file.
A new variable will be created named AgeBracket with 12 characters limit so the values are displayed properly.
If and else if are used to group 2 different values into one resulting in 3 final values.
Drop is used to remove age hence replaced by the new variable AgeBracket.
*/

data mylib.nos8;
set mylib.suicide;
Length AgeBracket $12;
if age = '5-14 years' then AgeBracket = "5-24 years";
else if age = '15-24 years' then AgeBracket = "5-24 years";
else if age = '25-34 years' then AgeBracket = "25-54 years";
else if age = '35-54 years' then AgeBracket = "25-54 years";
else if age = '55-74 years' then AgeBracket = "55-75+ years";
else if age = '75+ years' then AgeBracket = "55-75+ years";
drop age;
run;

proc freq data = mylib.nos8;
table AgeBracket;

/*2nd variable creation
To further increase the simplicity and understandability of the dataset we will add AgeGroup variable.
A new dataset nos1 is created and set is used to extract data from nos8 which was previously created.
Length is again used to make sure all the values are displayed without any cuts.
If and else if are used to create Agegroup variable where values from AgeBracket are divided into 
Elderly, Young and Middleaged.
*/

data mylib.nos1;
set mylib.nos8;
Length AgeGroup $12;
if AgeBracket='55-75+ years' then AgeGroup = "Elderly";
else if AgeBracket='25-54 years' then AgeGroup = "Middle aged";
else if AgeBracket='5-24 years' then AgeGroup = "Young";

run;

proc freq data = mylib.nos1;
table AgeGroup;




/**** ANALYSIS OF NUMERICAL VARIABLES *****/

title "proc means to list the numerical attributes & their descriptive statistics of suicide dataset";
proc means data = mylib.suicide n nmiss mean min max stddev maxdec=3;
run;

/*** Reporting Missing HDI Values ***/

title "Listing of country name and year with missing HDI variable";
data _null_;
   file print;                               ***send output to the output window;
   set mylib.suicide(keep = country year HDI_for_year);
   ***Check HDI_for_year variable;
   if (missing(HDI_for_year)) then
      put 
      country = year = ;
run;

/*** Reporting Invalid HDI Values ***/

title "Listing of country name and year with invalid HDI variable";
data _null_;
   file print;                               ***send output to the output window;
   set mylib.suicide(keep = country year HDI_for_year);
   ***Check HDI_for_year variable;
   if (HDI_for_year<0 or HDI_for_year>1) and not missing(HDI_for_year) then
      put 
      country = year =  HDI_for_year = ;
run;



/*** Deleting Invalid HDI Values ***/

data mylib.HDI_drop;
set mylib.suicide;
if (HDI_for_year<0 or HDI_for_year>1) and not missing(HDI_for_year) then delete;
run;

proc datasets library = mylib nolist;
   delete suicide;
run;

proc datasets library=mylib nolist;
   change HDI_drop = suicide;
run;

/* checking number of observations after deletion */

proc contents data = mylib.suicide;


/*** Replacing missing values with 0 using Imputation Method **/

title;
proc stdize data=mylib.suicide out= mylib.suicide_Imputed 
      reponly               /* only replace; do not standardize */
      missing=0;          
   var HDI_for_year;             
run;

proc datasets library = mylib nolist;
   delete suicide;
run;

proc datasets library=mylib nolist;
   change suicide_Imputed = suicide;
run;

/* Confirming that no missing values exist using proc means */

proc means data=mylib.suicide n nmiss mean min max stddev maxdec=3;
run;


/*** Creating dervid variable HDI_cat ***/

data mylib.suicide_binned; 
     set mylib.suicide; 
     format HDI_cat $30.; 
      
     if HDI_for_year = 0  then HDI_cat = 'Data Unavailable';
else if HDI_for_year > 0 and HDI_for_year < 0.550 then HDI_cat = 'Low Human Development';
else if HDI_for_year >= 0.550 and HDI_for_year <=0.699 then HDI_cat = 'Medium Human Development'; 
else if HDI_for_year >= 0.700 and HDI_for_year <=0.799 then HDI_cat = 'High Human Development';
else if HDI_for_year >= 0.800 then HDI_cat = 'Very High Human Development';     
run; 


proc datasets library = mylib nolist;
   delete suicide;
run;

proc datasets library=mylib nolist;
   change suicide_binned = suicide;
run;

title"computing frequencies of new variable 'HDI_cat'";
proc freq data = mylib.suicide;
tables HDI_cat;
run;


/*** comparing number of suicides for different HDI categories ***/

proc sgplot data = mylib.suicide;
    vbar HDI_cat / response=suicides_no group=suicides_no groupdisplay=cluster stat=mean;
    yaxis grid;
run;

/** Dropping HDI_for_year **/
data mylib.suicide ( drop = HDI_for_year);
set mylib.suicide;	    
run;

/** Outlier Detection **/

/** 1. variable: suicides_100k **/

title"box plot of suicides_100k";
proc sgplot data=mylib.suicide;
   vbox suicides_100k;
run;


title"Outliers based on Interqaurtile range";
proc means data = mylib.suicide;
   var suicides_100k;
   output out = Tmp
   Q1= 
   Q3= 
   QRange=  /autoname;
run;

data _null_;
   file print;
   set mylib.suicide (keep= country year suicides_100k);
   if _n_ = 1 then set Tmp;
   if suicides_100k le suicides_100k_Q1 - 1.5*suicides_100k_QRange and not missing(suicides_100k) or
      suicides_100k ge suicides_100k_Q3 + 1.5*suicides_100k_QRange then 
      put "possible outliers for record number " country= year= "Value of suicides number is " suicides_100k=;
run;

title"box plot of suicides_100k after removal";
data mylib.suicide_OutliersRemoved;
   set mylib.suicide;
   if _n_ = 1 then set Tmp;
   if suicides_100k le suicides_100k_Q1 - 1.5*suicides_100k_QRange and not missing(suicides_100k) or
      suicides_100k ge suicides_100k_Q3 + 1.5*suicides_100k_QRange then delete;
run; 

proc sgplot data=mylib.suicide_OutliersRemoved;
   vbox suicides_100k;
run;


/** 2. variable: gdp_per_capita **/

title"box plot of gdp per capita";
proc sgplot data=mylib.suicide;
   vbox gdp_per_capita;
run;


title"Outliers based on Interqaurtile range";
proc means data = mylib.suicide;
   var gdp_per_capita;
   output out = Tmp
   Q1= 
   Q3= 
   QRange=  /autoname;
run;

data _null_;
   file print;
   set mylib.suicide (keep= country year gdp_per_capita);
   if _n_ = 1 then set Tmp;
   if gdp_per_capita le gdp_per_capita_Q1 - 1.5*gdp_per_capita_QRange and not missing(gdp_per_capita) or
      gdp_per_capita ge gdp_per_capita_Q3 + 1.5*gdp_per_capita_QRange then 
      put "possible outliers for record number " country= year= "Value of gdp per capita is " gdp_per_capita=;
run;


data mylib.suicide_OutliersRemoved1;
   set mylib.suicide;
   if _n_ = 1 then set Tmp;
   if gdp_per_capita le gdp_per_capita_Q1 - 1.5*gdp_per_capita_QRange and not missing(gdp_per_capita) or
      gdp_per_capita ge gdp_per_capita_Q3 + 1.5*gdp_per_capita_QRange then delete;
run; 

title"box plot of gdp per capita after outlier removal";
proc sgplot data=mylib.suicide_OutliersRemoved1;
   vbox gdp_per_capita;
run;





/********* Test For Normality *************/

/**** 1. variable : suicides_100k ***/

ods select TestsForNormality Plots histogram;
proc univariate data=mylib.suicide Normal Plot;
var suicides_100k;
histogram / normal;
run;
ods trace off;


data mylib.suicide_transformed1;
set mylib.suicide;
log_suicides_100k=log(suicides_100k);
root4_suicides=suicides_100k**0.25;


run;


ods select TestsForNormality plots;
proc univariate data=mylib.suicide_transformed1 normal plot;
var log_suicides_100k root4_suicides;
run;
ods trace off;


/**** 2. variable : gdp_per_capita ***/

ods select TestsForNormality Plots histogram;
proc univariate data=mylib.suicide Normal Plot;
var gdp_per_capita;
histogram / normal;
run;
ods trace off;


data mylib.suicide_transformed2;
set mylib.suicide;
log_gdp_per_capita=log(gdp_per_capita);
root4_gdp=gdp_per_capita**0.25;
run;


ods select TestsForNormality plots;
proc univariate data=mylib.suicide_transformed2 normal plot;
var log_gdp_per_capita root4_gdp;
run;
ods trace off;
















/**********************************************************************************/
