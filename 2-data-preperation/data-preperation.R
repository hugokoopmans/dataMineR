# data analysis template
# required libraries
library(DMwR)
#install.packages('discretization')
library(discretization)
#library(plyr)
#library(foreach)
library(rms)

# knitr uses Rmd fil location as working directory
# if we run script from Rstudio we need to put the right working dir
#setwd("~/r-studio/dataMineR/2-data-preperation")
setwd("~/Git/dataMineR/2-data-preperation")

# source newer version of this function
#source('knnImputation.R')

# we define knitr chunks here which  can be picked up by rnw files for document generation
i=1

## @knitr setup

# goto data file directory
#setwd("~/r-studio/TdH")



## @knitr read_data

#### parameters ####
# filename
filename <- "../data/data-analysis.tab"
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
n_vars <- length(var_names)
num_var_names <- names(data[sapply(data, is.numeric)])
num_vars <- length(num_var_names)
cat_var_names <- names(data[sapply(data, is.factor)])
cat_vars <- length(cat_var_names)

## @knitr target_def
target_name <- 'target'
# check if mising values in target 
if(length(which(is.na(data[[target_name]]))) > 0){
  cat('Warning : Removing',length(which(is.na(data[[target_name]]))), 'cases with missing target values.')
  data <- subset(data,! is.na(data[[target_name]]))
} 

# check if target is a factor, if not make it a factor
if (is.numeric(data[[target_name]])){
  data$target <- as.factor(data[[target_name]])} else {data$target <- data[[target_name]]
  }

# display counts and percentage on target
library(pander)
t <- cbind(table(data$target),100*prop.table(table(data$target)))
t <- as.data.frame(t)
# xt <- xtable(t)
# digits(xt) <- c(0,0,2)
names(t) <- c('count','%')
pander(t)

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
# somers Dxy by Frank Ahrrell
library(Hmisc)

# method still slow , sampling needed
ssize <- 100 # in percent of dataset
n <- round(nrow(data)*ssize/100)
s_data <- data[sample(nrow(data), size=n), ]

# create indices for all colums we want to do calculations
drops <- c("caseID","target")
idx <- which(!(names(data) %in% drops))

# function to calc correlation measure
myCorMeasures <- function(i=1, target="target",df=data) {
result <- cor.test(xtfrm(df[, i]), xtfrm(df[, target]), alternative="two.sided",method="kendall")$estimate
return(result)
}

# somers Dxy
mySomersDxy <- function(i=1, target="target",df=data) {
  # TODO recode categoricals properly
  # TODO get C area under curve
  # result is a vector not a dataframe so use [""] to access attributes
  Dxy <- somers2(as.numeric(df[, i]), as.numeric(df[, target])-1)["Dxy"]
  C <- somers2(as.numeric(df[, i]), as.numeric(df[, target])-1)["C"]
  return(Dxy)
}

# todo add gini and other quality measures somers Dxy

# list of correlations of variables to target
correlation.Tau <- lapply(idx,myCorMeasures,df=s_data)
correlation.Dxy <- lapply(idx,mySomersDxy,df=s_data)

# make a numeric vector
nTau <- as.numeric(correlation.Tau)
nDxy <- as.numeric(correlation.Dxy)

#  wrld_data[order(wrld_data$NAME),]
# dd[with(dd, order(-z, b)), ]
name <- names(data[,idx])
t <- data.frame(name,nTau,nDxy)
# sort correlation ascending 
t_sorted <- t[with(t, order(nTau)), ]

#digits(xt) <- c(0,2,4)
names(t_sorted) <- c('variable','Kendalls Tau','Somers Dxy')
library(pander)
pander(t_sorted)

## @knitr run-recode
out = NULL
for (i in c(1:n_vars)) {
  out = c(out, knit_child('dp-recode.Rmd'))
}

## @knitr never

# test recoding and binning
#load tree package
library(rpart)
fit1<-rpart(outcome~income,data=data,parms=list(prior=c(.95,.05)),cp=.001,method="class",x = TRUE,y = TRUE)
par(mfrow = c(1,1), xpd = NA)
plot(fit1);text(fit1,cex=0.5);
printcp(fit1)
plotcp(fit1)

fit1$cptable[which.min(fit1$cptable[,"xerror"]),"CP"]

# prune the tree 
pfit1 <- prune(fit1, cp = fit1$cptable[which.min(fit1$cptable[,"xerror"]),"CP"])
pfit1

library(randomForest)

arf<-randomForest(target~age,data=data,importance=TRUE,proximity=TRUE,ntree=50, keep.forest=TRUE)
#plot variable importance
varImpPlot(arf)

#conditional inference trees corrects for known biases in chaid and cart
library(party)
data$outcome <- as.factor(data$target)
data$target <- NULL
cfit2 <- ctree(outcome~age+income+gender,data=data, control = ctree_control( mincriterion = 0.6))
plot(cfit2);
table(predict(cfit1), data$taget)

irisct <- ctree(Species ~ .,data = iris)
irisct
plot(irisct)
table(predict(irisct), iris$Species)

hist(data$age, breaks = 5)