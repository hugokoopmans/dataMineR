Data Analysis Report
========================================================

Todo : add table of content

Introduction
------------------------
This data analysis report is generated using R-studio and knitr to knit R code and markdown into html format. We have the option to include all R code that is used to generate the plots and calculations. Default this feauture is dissabled.
The data analysis step is the first step an a datamining analysis.

Dataset Basic Artifacts 
------------------------------------
Basic information from the dataset we are using.

### Basic dataset information







We are using data from file : d5.tab
The dataset has 37 variables and 59992 rows.  

The case identifyer is *registrnr* this is unique for all cases.

Variabele types
-----------------------------


The following variabeles are present in the dataset:
jaarbedr, minbegjr, proj, nudona, r20102009mndbedrag, r20112010mndbedrag, X2009avgbedragmnd, X2010avgbedragmnd, X2011avgbedragmnd, bronaktie, bronlaatstebetwijze, Jaarbinnen, sexe, leeftijd2011, Bronbinnen, mailingen, magpost, magdigi, diginws, TM, mail07, catHHINKOMEN, catHHSOCIALE, catHHOPLEIDI, catHHLEVENSF, catHHGEOTYPE, catHHTYPEWO, catHHEIGENDO, catHHWOZWAA, catBELEGGERS, catLENERS, catSPAARDERS, catSWITCHGEVO, catMERKENTROU 

We have 13 numeric variables and 21 categorical variables (or factors in R).


Excluded variables
------------------------------
From the varables provided the folowing list will be excluded in this anlysis: ``caseID, registrnr, X2011tmoktstornaant, X2010stornoaantal``

Sometimes categoric variables are present as coded numbers. These should be treated as factors.
In this dataset the following variables will be used as factors(categoric): ``catHHINKOMEN, catHHSOCIALE, catHHOPLEIDI, catHHLEVENSF, catHHGEOTYPE, catHHTYPEWO, catHHEIGENDO, catHHWOZWAA, catBELEGGERS, catLENERS, catSPAARDERS, catSWITCHGEVO, catMERKENTROU``

We have ``13`` numeric variables and ``21`` categorical variables (or factors in R).

Numeric variables
=============================
Here we analyse all numeric variables. We start with an overview on basic statistics per variable. We check for missing values. We do a histogram plot to show the distribution for this variable. And we test for outliers.


Overview
-----------------------------
In the table below we report the number of observations (n), the smallest observation (min),  the first quantile (q1), the media ,  the mean, last quantile, the largest observation (max), and the nber of missing values (na).

<!-- html table generated in R 2.14.1 by xtable 1.7-1 package -->
<!-- Fri May 24 22:02:03 2013 -->
<TABLE border=1>
<TR> <TH>  </TH> <TH> td.mean </TH> <TH> td.median </TH>  </TR>
  <TR> <TD align="right"> jaarbedr </TD> <TD align="right"> 79.21 </TD> <TD align="right"> 60.00 </TD> </TR>
  <TR> <TD align="right"> minbegjr </TD> <TD align="right"> 2003.23 </TD> <TD align="right"> 2008.00 </TD> </TR>
  <TR> <TD align="right"> proj </TD> <TD align="right"> 0.33 </TD> <TD align="right"> 0.00 </TD> </TR>
  <TR> <TD align="right"> nudona </TD> <TD align="right"> 0.89 </TD> <TD align="right"> 1.00 </TD> </TR>
  <TR> <TD align="right"> r20102009mndbedrag </TD> <TD align="right"> 1.00 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> r20112010mndbedrag </TD> <TD align="right"> 1.05 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> X2009avgbedragmnd </TD> <TD align="right"> 6.41 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> X2010avgbedragmnd </TD> <TD align="right"> 6.36 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> X2011avgbedragmnd </TD> <TD align="right"> 6.63 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> Jaarbinnen </TD> <TD align="right"> 2000.81 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> leeftijd2011 </TD> <TD align="right"> 53.25 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> mailingen </TD> <TD align="right"> 86.23 </TD> <TD align="right">  </TD> </TR>
  <TR> <TD align="right"> magpost </TD> <TD align="right"> 8.01 </TD> <TD align="right">  </TD> </TR>
   </TABLE>


 
