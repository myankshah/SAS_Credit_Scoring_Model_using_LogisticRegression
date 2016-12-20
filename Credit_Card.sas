/*Regression- Graded Assignment*/

/*Permanent Library**/
libname reg "D:\Users\ms\Graded Assignments\Topic 10-Case Study Regression-Graded";
run;

/*Importing the dataset*/
proc import
datafile = "Z:\Assignments\Graded Assignment\Topic 10 -  Regression Models\Credit.csv"
out = reg.creditcard dbms =csv replace;
run;


/*Mandate data exploration finding frequencies of 0's and 1's*/ 
proc freq data = reg.creditcard;
tables NPA_Status;
run;


/*Data Exploration*/
proc means data = reg.creditcard n nmiss mean stddev min max range;
proc freq data = reg.creditcard;
tables Numberofdependents Gender MonthlyIncome;
proc contents data= reg.creditcard;
run;

/*Data Cleaning and removing missing values from number of dependents variable*/
data reg.creditcard1 (drop = MonthlyIncome1);
set reg.creditcard;
if numberofdependents = "Goo" or numberofdependents="Bad" then delete;
run;


/*Data Exploration after removing missing values*/
proc means data = reg.creditcard1 n nmiss mean min max;

proc freq data = reg.creditcard1;
tables Numberofdependents Gender MonthlyIncome Education Occupation Rented_OwnHouse;

proc freq data = reg.creditcard1;
tables NPA_Status;
run;


/*Data Cleaning and substitution on MonthlyIncome and Number of Dependents*/
data reg.creditcard2;
set reg.creditcard1;
if MonthlyIncome>= 1000000 then delete;
MonthlyIncome1 = input(MonthlyIncome,12.) ;
NumberOfDependents1 = input(NumberOfDependents,10.);
run;
proc means data = reg.creditcard2;
var MonthlyIncome1 NumberOfDependents1;
run;

/*Substituting mean for missing values in MonthlyIncome and Number of Dependents*/
data reg.creditcard3 (drop = MonthlyIncome NumberOfDependents);
set reg.creditcard2;
if MonthlyIncome1 = . then MonthlyIncome1 = 6608; 
if NumberOfDependents1 = . then NumberOfDependents1 = 1; 
run;
proc freq data = reg.creditcard3;
tables MonthlyIncome1 NumberOfDependents1;
run;




/*Data Preparation
dummy variables for :Age,Region,Income,house ownership,Occupation,Education,Gender */

*AGE;
data reg.prep;
set reg.creditcard3;
if age le 30 then age30 = 1;
else age30 = 0;
if 31 le age le 45 then age45 = 1;
else age45 = 0;
if 46 le age le 60 then age60 = 1;
else age60 = 0;
if 61 le age le 75 then age75 = 1;
else age75 = 0;
if age gt 76 then age75 = 1;
else age75 = 0;

*REGION;
if region = "Centr" then region_c = 1;
else region_c = 0;
if region = "North" then region_n = 1;
else region_n = 0;
if region = "East" then region_e = 1;
else region_e = 0;
if region = "South" then region_s = 1;
else region_s = 0;
if region = "West" then region_w = 1;
else region_w = 0;

*INCOME;
monthly_income =input(MonthlyIncome1,best32.);
length income $25;
if 0 le monthly_income le 10000 then income = "0-10000";
else if 10001 le monthly_income le 50000 then income = "10001-50000";
else if 50001 le monthly_income le 100000 then income = "50001-100000";
else if 100001 le monthly_income le 250000 then income = "100001-250000";
else if 250001 le monthly_income le 500000 then income = "250001-500000";
else if 500001 le monthly_income le 750001 then income = "500001-750000";
else if 750001 le monthly_income le 999999 then income= "750001-999999";

if income  = "0-10000" then income_cat1 = 1;
else income_cat1 = 0;
if income  = "50001-100000" then income_cat2 = 1;
else income_cat2 = 0;
if income  = "100001-250000" then income_cat3 = 1;
else income_cat3 = 0;
if income  = "250001-500000" then income_cat4 = 1;
else income_cat4 = 0;
if income  = "500001-750000" then income_cat5 = 1;
else income_cat5 = 0;
if income  = "750001-999999" then income_cat6 = 1;
else income_cat6 = 0;

*house ownership;
if rented_ownhouse = "Ownhouse" then house_owner_1 = 1;
else house_owner_1 = 0;
if rented_ownhouse = "Rented" then house_owner_2 = 1;
else house_owner_2 = 0;

*occupation;
if occupation = "Non-offi" then job1 = 1;
else job1 = 0;
if occupation = "Officer1" then job2 = 1;
else job2 = 0;
if occupation = "Officer2" then job3 = 1;
else job3 = 0;
if occupation = "Officer3" then job4 = 1;
else job4 = 0;
if occupation = "Self_Emp" then job5 = 1;
else job5 = 0;

*Education;
if Education = "Matric" then edu1 = 1;
else edu1 = 0;
if Education = "Graduate" then edu2 = 1;
else edu2 = 0;
if Education = "Post-Grad" then edu3 = 1;
else edu3 = 0;
if Education = "PhD" then edu4 = 1;
else edu4 = 0;
if Education = "Professional" then edu5 = 1;
else edu5 = 0;

*Gender;
if Gender = "Male" then gend1 = 1;
else gend1 = 0;
if Gender = "Female" then gend2 = 1;
else gend2 = 0;
run;


/*Identifying Outliers*/
proc univariate data = reg.prep;
var revolvingutilizationofunsecuredl debtratio numberoftimes90dayslate 
numberoftime60_89dayspastduenotw numberoftime30_59dayspastduenotw;
run;

/*detecting outliers in revolvingutilizationofunsecuredl variable and substituting
the mean and deleteing extreme values*/
proc means data = reg.prep n nmiss min max mean;
var revolvingutilizationofunsecuredl;
run;
data reg.prep2;
set reg.prep;
if revolvingutilizationofunsecuredl >5 then delete;
if 5 gt revolvingutilizationofunsecuredl >1  then revolvingutilizationofunsecuredl = 0.32;
run;
proc means data = reg.prep2 n nmiss min max mean;
var revolvingutilizationofunsecuredl;
run;


/*removing extreme values from age*/
data  reg.prep2;
set reg.prep2;
if age = 0 then age = 52;
run;
proc means data = reg.prep2 n nmiss mean min;
var age;
run;


/*removing outliers from Number of times days past due (30-59,60-90,>90*/
data reg.prep3(drop = MonthlyIncome NumberOfDependents Income_cat7);
set reg.prep2;
if NumberOfTime30_59DaysPastDueNotW >=96 then delete;
if NumberOfTime60_89DaysPastDueNotW >=96 then delete;
if NumberOfTimes90DaysLate >=96 then delete;
if debtratio > 1 then debtratio = 0.5;
run;

proc means data =  reg.prep3;
run;


proc univariate data = reg.prep3;
var revolvingutilizationofunsecuredl debtratio numberoftimes90dayslate 
numberoftime60_89dayspastduenotw numberoftime30_59dayspastduenotw NumberOfDependents1;
run;


/*****End of Data Exploration and Data Preparation*********************/


/*****Start of Model Building******************************************/


/*partitioning data into development and validation dataset*/
data reg.development reg.validation;
set reg.prep3;
if ranuni (100) <0.60 then output reg.development;
else output reg.validation;
run;


/*counting 0's and 1's in development and validation dataset*/
proc freq data = reg.development;
tables NPA_Status;
run;

proc freq data = reg.validation;
tables NPA_Status;
run;




/*Running Logistic Regression : iteration 1*/
proc logistic data= reg.development descending;
model NPA_Status = age30 age45 age60 age75 region_c region_n region_e region_s
region_w income_cat1 income_cat2 income_cat3 income_cat4 income_cat5 income_cat6
 house_owner_1 house_owner_2 job1 job2 job3 job4 job5 edu1 edu2 edu3 edu4
edu5 gend1 gend2 RevolvingUtilizationOfUnsecuredL NumberOfTime30_59daysPastDueNotW
NumberOfTime60_89daysPastDueNotW DebtRatio NumberOfTimes90DaysLate NumberOfOpenCreditLinesAndLoans
NumberRealEstateLoansOrLines;
output out = reg.creditscore1 predicted = pred_prob;
run;

/*iteration 2- model with only significant variables*/
proc logistic data= reg.development descending;
model NPA_Status = age30 age45 age60 region_c region_n region_e region_s income_cat1 house_owner_1 job1 job3 edu1 edu3 edu4
RevolvingUtilizationOfUnsecuredL NumberOfTime30_59daysPastDueNotW
NumberOfTime60_89daysPastDueNotW DebtRatio NumberOfTimes90DaysLate NumberOfOpenCreditLinesAndLoans
NumberRealEstateLoansOrLines;
output out = reg.creditscore2 predicted = pred_prob;
run;


/*Auto iteration - forward Selection*/
proc logistic data= reg.development descending;
model NPA_Status = age30 age45 age60 region_c region_n region_e region_s income_cat1 house_owner_1 job1 job3 edu1 edu3 edu4
RevolvingUtilizationOfUnsecuredL NumberOfTime30_59daysPastDueNotW
NumberOfTime60_89daysPastDueNotW DebtRatio NumberOfTimes90DaysLate NumberOfOpenCreditLinesAndLoans
NumberRealEstateLoansOrLines/selection = forward ;
output out = reg.creditscore3 predicted = pred_prob;
run;

/*Auto iteration - backward Selection*/
proc logistic data= reg.development descending;
model NPA_Status = age30 age45 age60 region_c region_n region_e region_s income_cat1 house_owner_1 job1 job3 edu1 edu3 edu4
RevolvingUtilizationOfUnsecuredL NumberOfTime30_59daysPastDueNotW
NumberOfTime60_89daysPastDueNotW DebtRatio NumberOfTimes90DaysLate NumberOfOpenCreditLinesAndLoans
NumberRealEstateLoansOrLines/selection = forward ;
output out = reg.creditscore3 predicted = pred_prob;
run;




/*Final Iteration with signifant variable at 0.05 only*/
proc logistic data= reg.development descending;
model NPA_Status = age30 age45 age60 region_c region_n region_e region_s income_cat1 house_owner_1 job1 job3 edu1 edu3 edu4
RevolvingUtilizationOfUnsecuredL NumberOfTime30_59daysPastDueNotW
NumberOfTime60_89daysPastDueNotW DebtRatio NumberOfTimes90DaysLate NumberOfOpenCreditLinesAndLoans
NumberRealEstateLoansOrLines;
output out = reg.creditscore4 predicted = pred_prob;
run;

proc sort data = reg.creditscore4 out = reg.creditscore4_sorted;
by descending pred_prob;
run;
proc export data = reg.creditscore4_sorted
outfile = "Y:\Graded Assignments\Topic 10-Case Study Regression-Graded\Solution\log_reg.csv"
dbms = csv replace;
run;

proc rank data = reg.creditscore4_sorted out = reg.decile groups = 10 ties = mean;
var pred_prob;
ranks decile;
run;

proc export data = reg.decile
outfile = "Y:\Graded Assignments\Topic 10-Case Study Regression-Graded\Solution\lift_chart.csv"
dbms = csv replace;
run;

/*Scoring a new dataset - Confusion Matrix*/

proc logistic data= reg.development descending;
model NPA_Status = age30 age45 age60 region_c region_n region_e region_s income_cat1 house_owner_1 job1 job3 edu1 edu3 edu4
RevolvingUtilizationOfUnsecuredL NumberOfTime30_59daysPastDueNotW
NumberOfTime60_89daysPastDueNotW DebtRatio NumberOfTimes90DaysLate NumberOfOpenCreditLinesAndLoans
NumberRealEstateLoansOrLines/lackfit;
output out = reg.creditscore5 predicted = pred_prob;
score data = reg.validation out = reg.reg_out;
run;

proc freq data = reg.reg_out;
tables F_NPA_Status*I_NPA_Status/nopercent norow nocol nocum;
run;

/************End of Development Dataset Modelling********************/

/************Validation of Model*************************************/
proc logistic data= reg.validation descending;
model NPA_Status = age30 age45 age60 region_c region_n region_e region_s income_cat1 house_owner_1 job1 job3 edu1 edu3 edu4
RevolvingUtilizationOfUnsecuredL NumberOfTime30_59daysPastDueNotW
NumberOfTime60_89daysPastDueNotW DebtRatio NumberOfTimes90DaysLate NumberOfOpenCreditLinesAndLoans
NumberRealEstateLoansOrLines;
output out = reg.model_validation predicted = pred_prob;
run;

proc sort data = reg.model_validation out = reg.model_validation_sorted;
by descending pred_prob;
run;
proc export data = reg.model_validation_sorted
outfile = "Y:\Graded Assignments\Topic 10-Case Study Regression-Graded\Solution\validation_log_reg.csv"
dbms = csv replace;
run;

proc rank data = reg.model_validation_sorted out = reg.model_validation_decile groups = 10 ties = mean;
var pred_prob;
ranks decile;
run;

proc export data = reg.model_validation_decile
outfile = "Y:\Graded Assignments\Topic 10-Case Study Regression-Graded\Solution\validation_gain_chart.csv"
dbms = csv replace;
run;


/*Scoring-Confusion Matrix*/
proc logistic data= reg.validation descending;
model NPA_Status = age30 age45 age60 region_c region_n region_e region_s income_cat1 house_owner_1 job1 job3 edu1 edu3 edu4
RevolvingUtilizationOfUnsecuredL NumberOfTime30_59daysPastDueNotW
NumberOfTime60_89daysPastDueNotW DebtRatio NumberOfTimes90DaysLate NumberOfOpenCreditLinesAndLoans
NumberRealEstateLoansOrLines/lackfit;
output out = reg.model_validation predicted = pred_prob;
score data = reg.development out = reg.reg_out1;
run;
proc freq data = reg.reg_out;
tables F_NPA_Status*I_NPA_Status/nopercent norow nocol nocum;
run;

