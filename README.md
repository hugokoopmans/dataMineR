dataMineR
=========

Update 7/6/2013
---------------

In step 1, we now render tables in extended (Pandoc) markdown. This means that Pandoc can be used to output either pdf or html in a well-formatted way.


Update
-----------
We are now transforming from latex to markdown

R scripts for datamining.

This project aims to efficiently implement the CRISP datamining cycle.
Initially we focus on supervised models for dichotomous class predictive models.

The project tries to combine R scripts with knitr in R-studio in such a way that we walk through the CRISP phases and deliver a scoring model in the most efficient way.
In the meantime we would like to document our steps in a report that is nice enough to be used a reference of the work been done.

From wikipedia:
CRISP-DM breaks the process of data mining into six major phases:
- Business Understanding
- Data Understanding
- Data Preparation
- Modelling
- Evaluation
- Deployment

In this project we focus on automating the steps of Data Understanding, Data Preparation, Modelling, Evaluation.

HowTo
-------------
Put your data file into the data directory.
Point the data-analysis.R to the right file name, to do this chage line

path2file <- "../data/ano_churn_data.Rdata"

to point to your filename.

Be sure to have your target variable named "target" or adjust target_name in file Data-Prperation-Report.Rmd to whatever you want to predict in your dataset

# target defenition
target_name <- 'target'

Run step by step

