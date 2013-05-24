# data analysis template
# we define knitr chunks here which  can be picked up by Rnw or Rmd files for document generation

## @knitr read_data
i=1
# goto data file directory
setwd("~/r-studio/TdH")

# filename
filename <- "d5.tab"

# read dataframe from tab delimets file
data <- read.delim(filename,strip.white = TRUE)

# determine number of rows and colums in dataframe
rows <- nrow(data)
colums <- ncol(data)

# case_id = registrnr
original_case_id = 'registrnr'
data$caseID <- data$registrnr

# check if case_id is unique
if( ! (length(unique(data$caseID)) == length(data$caseID)) ){
        cat('Warning : Case_id appears not unique ! ')}

# exclude original case_id and variables with lot of missing
exclude_var_names <- c('caseID','registrnr','X2011tmoktstornaant','X2010stornoaantal')
data <- data[,!names(data) %in% exclude_var_names]

## @knitr var_types
# names in header
var_names <- names(data)

# sometimes variabels are in the dataset as codes, they appear numeric but code for a category
treat_as_categorical <- c("catHHINKOMEN","catHHSOCIALE","catHHOPLEIDI","catHHLEVENSF","catHHGEOTYPE","catHHTYPEWO",
"catHHEIGENDO","catHHWOZWAA", "catBELEGGERS","catLENERS",   "catSPAARDERS","catSWITCHGEVO"      
,"catMERKENTROU")

# transform numeric into factors
data[treat_as_categorical] <- lapply(data[treat_as_categorical], as.factor)

num_var_names <- names(data[sapply(data, is.numeric)])
num_vars <- length(num_var_names)
cat_var_names <- names(data[sapply(data, is.factor)])
cat_vars <- length(cat_var_names)

## @knitr num-overview
library(reporttools)
# summarize numeric variables
tableContinuous(data[,sapply(data, is.numeric)],stats = c("n", "min", "q1", "median", "mean", "q3", "max", "na"))

## @knitr num-overview-md
library(xtable)

# summarize numeric variables
td <- data[,sapply(data, is.numeric)]
td.min <- sapply(td,min)
td.mean <- sapply(td,mean,na.rm = TRUE)
td.median <- sapply(td,median)
td.max <- sapply(td,max)
td.n <- as.numeric(apply(td, 2, function(x) length(which(!is.na(x)))))
td.na <- as.numeric(apply(td, 2, function(x) length(which(is.na(x)))))

tddf <- cbind(td.mean,td.median)

#xtable(tddf)
print(xtable(tddf),type='html')


## @knitr run-numeric

# # run numeric template for each numeric variable seperately
out = NULL
for (i in c(1:num_vars)) {
  out = c(out, knit_child('da-numeric-template.Rnw', sprintf('da-numeric-template-%d.txt', i)))
}

# use describe from rms package
# library(rms)
# 
# latex(describe(data[num_var_names]),descript='dataset')


## @knitr cat-overview
library(reporttools)
cat_dat <- data[sapply(data, is.factor)]
# check number of levels per factor
cat_levels <-  sapply(cat_dat,nlevels)
max_levels <- 25
cat_dat_limited_levels <- cat_dat[,cat_levels <= max_levels]
cat_dat_not_reported <- cat_dat[,cat_levels > max_levels]

# keep only those with limited number of factors for reporting
cat_var_names_lim <- names(cat_dat_limited_levels)
cat_var_names_not_reported <- names(cat_dat_not_reported)
num_cat_vars_lim <- length(cat_var_names_lim)


## @knitr cat-levels
library(reporttools)

# report missing values
cat_num_missing <- colSums(is.na(cat_dat))
t <- data.frame(cat_levels,cat_num_missing)
# sort ascending 
#t_sorted <- t[with(t, order(nct)), ]
xt <- xtable(t)
digits(xt) <- c(0,0,0)
names(xt) <- c('levels','# missings')
print(xt)

## @knitr run-categoric
out = NULL
for (i in c(1:num_cat_vars_lim)) {
  out = c(out, knit_child('da-categorical-template.Rnw', sprintf('da-categorical-template-%d.txt', i)))
}

# summarize non numeric variables with less then max_levels levels
tableNominal(cat_dat_max)

## @knitr save-data
datasetName = "data-analysis.tab"
write.table(data,file = datasetName, sep = "\t", row.names=FALSE, quote = FALSE)

## @knitr run-never
for (i in c(1:num_vars)){
  print(num_var_names[i])
}


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


