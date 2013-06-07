# data analysis template
# required libraries
library(DMwR)
#install.packages('discretization')
library(discretization)
library(plyr)
library(foreach)

library(rms)

# source newer version of this function
source('knnImputation.R')

# we define knitr chunks here which  can be picked up by rnw files for document generation
i=1

## @knitr setup

# goto data file directory
setwd("~/r-studio/TdH")



## @knitr read_data

#### parameters ####
# filename
filename <- "data-analysis.tab"
# sample size in percentage
ssize = 10

# read dataframe from tab delimets file
data <- read.delim(filename)

# determine number of rows and colums in dataframe
rows <- nrow(data)
colums <- ncol(data)

## @knitr var_types

#datasetstructure <- str(data)
var_names <- names(data)
num_var_names <- names(data[sapply(data, is.numeric)])
num_vars <- length(num_var_names)
cat_var_names <- names(data[sapply(data, is.factor)])
cat_vars <- length(cat_var_names)
# target definition
target_name <- 'nudona'

## @knitr target_def

# check if mising values in target 
if(length(which(is.na(data[[target_name]]))) > 0){
  cat('Warning : Removing',length(which(is.na(data[[target_name]]))), 'cases with missing target values.')
  data <- subset(data,! is.na(data[[target_name]]))
} 

# check if target is a factor if not make it a factor
if (is.numeric(data[[target_name]])){
  data$target <- as.factor(data[[target_name]])} else {data$target <- data[[target_name]]
  }

# display counts and percentage on target
library(xtable)
t <- cbind(table(data$target),100*prop.table(table(data$target)))
xt <- xtable(t)
digits(xt) <- c(0,0,2)
names(xt) <- c('count','%')
print(xt)

## @knitr missing_def

# handel cases with missing data
# if number of cases that have missing data is limited the just drop the missing 
# otherwise we need more advanced replacement or imputation mechanisms
# or drop the variable that has the misssings

# list rows of data that have missing values
#length(which(!complete.cases(data)))

# create new dataset without missing data
data <- na.omit(data) 

# kNN missing value imputation
# todo get this to work in parrallel
##cleandata <- knnImputation2(data,k=5)

## @knitr raw_pred_cap
# kendall tau over all predictors

# method still slow , sampling needed

n <- round(nrow(data)*ssize/100)
s_data <- data[sample(nrow(data), size=n), ]

# create indices for all colums we want to calc correlation measure
drops <- c("id","target")
idx <- which(!(names(data) %in% drops))

# function to calc correlation measure
myCorMeasures <- function(i=1, target="target",df=data) {
result <- cor.test(xtfrm(df[, i]), xtfrm(df[, target]), alternative="two.sided",method="kendall")$estimate
return(result)
}

# todo add gini and other quality measures

# list of correlations of variables to target
correlation.Tau <- lapply(idx,myCorMeasures,df=s_data)

# # begin parrallel stuf
# library(parallel)
# 
# # set up the cluster
# size_of_pool = 4 
# cl <- makeCluster(size_of_pool)
# # do things in parrallel
# correlation.Tau <- parLapply(inds,myCorMeasures)
# 
# stopCluster(cl)
# # end parrallel stuff

# make a numeric vector
nct <- as.numeric(correlation.Tau)
#  wrld_data[order(wrld_data$NAME),]
# dd[with(dd, order(-z, b)), ]
library(xtable)
name <- names(data[,inds])
t <- data.frame(name,nct)
# sort correlation ascending 
t_sorted <- t[with(t, order(nct)), ]

xt <- xtable(t_sorted)
digits(xt) <- c(0,2,4)
names(xt) <- c('variable','Kendall Tau correlation')
print(xt,table.placement="H")

## @knitr run-recode
out = NULL
for (i in c(1:num_vars)) {
  out = c(out, knit_child('da-numeric-template.Rnw', sprintf('da-numeric-template-%d.txt', i)))
}

## @knitr cat-overview
library(reporttools)
cat_dat <- data[sapply(data, is.factor)]
# check number of levels per factor
cat_levels <-  sapply(cat_dat,nlevels)
max_levels <- 25
cat_dat_max <- cat_dat[,cat_levels < max_levels]
# keep only those with limited number of factors
cat_max_var_names <- names(cat_dat_max)
cat_max_vars <- length(cat_max_var_names)

## @knitr run-categoric
out = NULL
for (i in c(1:cat_max_vars)) {
  out = c(out, knit_child('da-categorical-template.Rnw', sprintf('da-categorical-template-%d.txt', i)))
}

# summarize non numeric variables with less then max_levels levels
tableNominal(cat_dat_max)

## @knitr run-never
for (i in c(1:num_vars)){
  print(num_var_names[i])
}

# test varclus

s <- ' ~ jaarbedr + minbegjr + proj + nudona + r20102009mndbedrag + r20112010mndbedrag + X2009avgbedragmnd + X2010avgbedragmnd'
v <- varclus(~ jaarbedr + minbegjr + proj + bronaktie + r20102009mndbedrag + r20112010mndbedrag + X2009avgbedragmnd + X2010avgbedragmnd, data = s_data)


# get the attribute estimate from the list of cor.test
sapply(cors, `[[`, "estimate")

# outlier test
library(outliers)
target <- "AantalMaandenWerkzaamVrouw"
target <- "Postcode4"
target <- "InkomenMaand"

x <- data[[target]]
outlier_tf = outlier(x,logical=TRUE)
#This gives an array with all values False, except for the outlier (as defined in the package documentation "Finds value with largest difference between it and sample mean, which can be an outlier").  That value is returned as True.
find_outlier = which(outlier_tf==TRUE,arr.ind=TRUE)
#This finds the location of the outlier by finding that "True" value within the "outlier_tf" array.
data_new = data[-find_outlier,]
#This creates a new dataset based on the old data, removing the one row that contains the outlier 

# extremevalues
library(extremevalues)
getOutliers(x, method="I",distribution="lognormal")

# kendaul correlation
cor(data$leeftijd2011,data$nudona, method="kendall")
cor(xtfrm(data$Bronbinnen),data$nudona, method="kendall")

xtfrm(data$catHHINKOMEN)


