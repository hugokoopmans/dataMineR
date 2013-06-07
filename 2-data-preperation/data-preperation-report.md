Data Preperation Report
========================================================

Todo : add ToC

Introduction
------------------------
This analysis report is generated using R, R-studio and knitr to knitr R code from markdown into html and later LateX format. We have the option to include all R code that is used to generate the plots and calculations. Default this feauture is dissabled.
The behaviour analysis step is the second step in a datamining analysis.
Steps identified in the datamining process are: 
* Data analysis 
* Behaviour analysis 
* Missing value analysis 
* Missing value imputation (optional) 
* Binning 
* Feature selection 
* Model development 
* Model analysis 
* Model deployment

Information on Dataset 
------------------------------------
Basic information from the dataset we are using.







We are using data from file : ../data/data-analysis.tab
The dataset has 5 variables and 5000 rows.

Variabele types
-----------------------------


The following variabeles are present in the dataset:
caseID, age, income, gender, target 

We have 4 numeric variables and 1 categorical variables (or factors in R).

Target defenition
-----------------------------
This analysis aims to report of the behaviour of each individual 'predictor' to a target variable. The target variable should be a categorical variable having two categories(or factor levels).  

The target variable is defined in the previous step.

The target has the following proportion of outcomes:

<!-- html table generated in R 2.14.1 by xtable 1.7-1 package -->
<!-- Tue Jun  4 22:41:25 2013 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> count </TH> <TH> % </TH>  </TR>
  <TR> <TD align="right"> 0 </TD> <TD align="right"> 176 </TD> <TD align="right"> 3.52 </TD> </TR>
  <TR> <TD align="right"> 1 </TD> <TD align="right"> 4824 </TD> <TD align="right"> 96.48 </TD> </TR>
   </TABLE>



Missing values
-------------------------
Before we can do model analysis we need to take care of missing values. The simplest appraoch is to delete cases including one or more missing entries but this can remove a large proportion of valuable data.
We can also remove individual variables if they have a high percentage of missing atributes.
Or we can replace or impute missing data with for instance an average or most frequent value. Actually changing the data. For this we can use kNN nearest neighbors. 

For now we will throw away all cases that have one or more missing attribute.

This dataset has 0 missing cases out of 5000, which is 0 percent.




Behaviour analysis
------------------------------
The selected inputs have the following raw predictive capacity:

<!-- html table generated in R 2.14.1 by xtable 1.7-1 package -->
<!-- Tue Jun  4 22:41:25 2013 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> variable </TH> <TH> Kendall Tau correlation </TH>  </TR>
  <TR> <TD align="right"> 1 </TD> <TD> age </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> 2 </TD> <TD> income </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> 3 </TD> <TD> gender </TD> <TD align="right">  </TD> </TR>
   </TABLE>

