/* Logistic regression analysis for disease outbreak data 

Observed variables: age, socio-economic status (upper, lower, middle),  

city sector (1,2) and disease (absence 0, presence 1).  

disease is the response variable */ 

data disease; 

infile "diseaseoutbreak_all.txt" firstobs=2 delimiter='09'x; 

input case age status sector disease; 

middleclass=(status=2); 

lowerclass=(status=3); 

dsector2=(sector=2); 

run; 

 

TITLE "Dataset"; 

proc print; 

run; 

 

 

TITLE "Full Model with Diagnostics"; 

* fit full model + options; 

proc logistic data=disease;  

model disease(event='1')=age middleclass lowerclass dsector2/ stb corrb influence iplots;  

run; 

 

* Split the data into training and test sets - 75/25; 

* samprate = 75% of observations to be randomly selected for training set 

* out = train defines new sas dataset for training/test sets; 

 

PROC SURVEYSELECT  

DATA = disease  

OUT = disease_all  

SEED = 50214284  

SAMPRATE = .75  

OUTALL; 

RUN; 

PROC PRINT; 

RUN; 

*Frequency table for selected field; 

PROC FREQ; 

TABLES SELECTED; 

RUN; 

* 

Create and populate the train_y variables 

This is used for building the model - model selection; 

DATA disease_all; 

SET disease_all; 

IF(Selected = 1) THEN train_y = disease; 

RUN; 

PROC PRINT; 

RUN; 

 

* 

Run model selection on training set; 

PROC LOGISTIC; 

MODEL train_y(event='1')= 

age 

middleclass 

lowerclass 

dsector2 

/ selection = stepwise rsquare stb; 

RUN; 

 

PROC LOGISTIC; 

MODEL train_y(event='1')= 

age 

dsector2 

/ ctable pprob = (.1 to .8 by .05); 

OUTPUT OUT = pred(where = (train_y=.)) p=phat lower=lcl upper=ucl; 

RUN; 

 

*print predicted prob; 

PROC PRINT DATA = pred; 

RUN; 

DATA probs; 

SET pred; 

IF (phat > .3) then pred_y = 1; 

ELSE pred_y = 0; 

RUN; 

PROC PRINT; 

RUN; 