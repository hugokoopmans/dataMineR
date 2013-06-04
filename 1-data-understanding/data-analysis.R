# data analysis template
# we define knitr chunks here which  can be picked up by Rnw or Rmd files for document generation

library(knitr)
setwd("~/r-studio/dataMineR/1-data-understanding")

## @knitr setup

# all inline!

## @knitr read_data
i=1

# data location full path to filename from working directory(=project dir)
path2file <- "../data/data-simple-example.tab"

# read dataframe from tab delimets file
data <- read.delim(path2file,sep = "\t",strip.white = TRUE)

# determine number of rows and colums in dataframe
rows <- nrow(data)
colums <- ncol(data)

# case_id = registrnr
original_case_id = 'caseID'
#data$caseID <- data$caseID

# map specific outcome field to target
# remove outcome field so scripts can work uniformly from here on
data$target <- data$y
data$y <- NULL

# check if case_id is unique
if( ! (length(unique(data$caseID)) == length(data$caseID)) ){
        cat('Warning : Case_id appears not unique ! ')}

# exclude original case_id and variables with lot of missing
#exclude_var_names <- c('caseID','registrnr','X2011tmoktstornaant','X2010stornoaantal')
exclude_var_names <- c('p_y','p_real')
data <- data[,!names(data) %in% exclude_var_names]

## @knitr var_types
# names in header
var_names <- names(data)

# sometimes variabels are in the dataset as codes, they appear numeric but code for a category

##treat_as_categorical <- c("catHHINKOMEN","catHHSOCIALE","catHHOPLEIDI","catHHLEVENSF","catHHGEOTYPE","catHHTYPEWO",
##"catHHEIGENDO","catHHWOZWAA", "catBELEGGERS","catLENERS",   "catSPAARDERS","catSWITCHGEVO"      
##,"catMERKENTROU")
treat_as_categorical <- NULL

# transform numeric into factors
data[treat_as_categorical] <- lapply(data[treat_as_categorical], as.factor)

# remove caseID from list of var names to be analysed
d2a <- subset(data, select = -c(caseID,target))
num_var_names <- names(d2a[sapply(d2a, is.numeric)])
num_vars <- length(num_var_names)
cat_var_names <- names(d2a[sapply(d2a, is.factor)])
cat_vars <- length(cat_var_names)

## @knitr num-overview-lx
library(reporttools)
# summarize numeric variables
tableContinuous(data[,sapply(data, is.numeric)],stats = c("n", "min", "q1", "median", "mean", "q3", "max", "na"))

## @knitr num-overview-md
library(xtable)

# summarize numeric variables
td <- data[,sapply(data, is.numeric)]
td.min <- sapply(td,min,na.rm = TRUE)
td.mean <- sapply(td,mean,na.rm = TRUE)
td.median <- sapply(td,median,na.rm = TRUE)
td.max <- sapply(td,max,na.rm = TRUE)
td.n <- as.numeric(apply(td, 2, function(x) length(which(!is.na(x)))))
td.na <- as.numeric(apply(td, 2, function(x) length(which(is.na(x)))))
td.q <- apply(td,2,quantile,na.rm = TRUE)

tddf <- data.frame(cbind(td.n,td.na,td.min,td.mean,td.median,td.max))
names(tddf) <- c('n obs','n missing','min','mean','median','max')

print(xtable(tddf),type='html')

## run numeric template for each numeric variable seperately

## @knitr run-numeric-lx
out = NULL
for (i in c(1:num_vars)) {
  out = c(out, knit_child('da-numeric-template.Rnw', sprintf('da-numeric-template-%d.txt', i)))
}

## @knitr run-numeric-md
out = NULL
for (i in c(1:num_vars)) {
  out = c(out, knit_child('da-numeric.Rmd'))
}

## @knitr run-all-md
out = NULL
for (i in 1:3) {
  out = c(out, knit_child('020-for-template.Rmd'))
}

## @knitr cat-overview
c_data <- data[sapply(data, is.factor)]
# check number of levels per factor
c_levels <-  sapply(c_data,nlevels)
max_levels <- 25
# trick if only one colum left we need to make sure still a dataframe to keep the names attached
c_data.limited_levels <- c_data[,c_levels <= max_levels, drop=FALSE ]
c_data.not_reported <- c_data[,c_levels > max_levels]

# keep only those with limited number of factors for reporting
c_var_names <- names(c_data.limited_levels)
if (ncol(c_data.not_reported) == 0){
  c_var_names.not_reported <- c('no variabes to report')
} else {
  c_var_names.not_reported <- names(c_data.not_reported)
}
num_c_vars_lim <- length(c_var_names)

## @knitr cat-levels-lx
library(reporttools)

# report missing values
c_num_missing <- colSums(is.na(c_data))
t <- data.frame(c_levels,c_num_missing)
# sort ascending 
#t_sorted <- t[with(t, order(nct)), ]
# xt <- xtable(t)
# digits(xt) <- c(0,0,0)
# names(xt) <- c('levels','# missings')
# print(xt)

## @knitr cat-levels-md

# report missing values
c_num_missing <- colSums(is.na(c_data))
t <- data.frame(c_levels,c_num_missing)
# sort ascending 
#t_sorted <- t[with(t, order(nct)), ]
xt <- xtable(t)
digits(xt) <- c(0,0,0)
names(xt) <- c('levels','# missings')

print(xtable(xt),type='html')

## @knitr run-categoric-md
out = NULL
for (i in c(1:num_c_vars_lim)) {
  out = c(out, knit_child('da-categorical.Rmd'))
}

# summarize non numeric variables with less then max_levels levels
#tableNominal(cat_dat_max)

## @knitr save-data
datasetName = "../data/data-analysis.tab"
write.table(data,file = datasetName, sep = "\t", row.names=FALSE, quote = FALSE)

## @knitr run-never
for (i in c(1:num_vars)){
  print(num_var_names[i])
}


# outlier test
library(outliers)
target <- ""

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


