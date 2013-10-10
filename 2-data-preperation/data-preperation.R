# data analysis template
# required libraries
library(DMwR)
library(discretization)
library(rms)

# parralel stuff
#library(plyr)
#library(foreach)

# source newer version of this function
#source('knnImputation.R')

# we define knitr chunks here which  can be picked up by rnw files for document generation
i=1

## @knitr setup

# goto data file directory
#setwd("~/r-studio/xyz")

# knitr uses Rmd file location as working directory
# if we run script from Rstudio we need to put the right working dir
setwd("~/r-studio/dataMineR/2-data-preperation")

## @knitr read_data

#### parameters ####
# filename
#filename <- "../data/data-analysis.tab"
filename <- "../data/data-set.Rdata"

# read dataframe from tab delimets file
# data_set <- read.delim(filename)

load(filename)

# determine number of rows and colums in dataframe
rows <- nrow(data_set)
colums <- ncol(data_set)

## @knitr var_types

#datasetstructure <- str(data)
var_names <- names(data_set)
n_vars <- length(var_names)
num_var_names <- names(data_set[sapply(data_set, is.numeric)])
num_vars <- length(num_var_names)
cat_var_names <- names(data_set[sapply(data_set, is.factor)])
cat_vars <- length(cat_var_names)

## @knitr target_def
# check if mising values in target 
if(length(which(is.na(data_set[[target_name]]))) > 0){
  cat('Warning : Removing',length(which(is.na(data_set[[target_name]]))), 'cases with missing target values.')
  data_set <- subset(data_set,! is.na(data_set[[target_name]]))
} 

# check if target is a factor, if not make it a factor
if (is.numeric(data_set[[target_name]])){
  data_set[[target_name]] <- as.factor(data_set[[target_name]])
  }

# display counts and percentage on target
library(pander)
t <- cbind(table(data_set[[target_name]]),100*prop.table(table(data_set[[target_name]])))
t <- as.data.frame(t)
# xt <- xtable(t)
# digits(xt) <- c(0,0,2)
names(t) <- c('count','%')
pander(t)

## @knitr missing_def

require(randomForest)
# handel cases with missing data
# if number of cases that have missing data is limited the just drop the missing 
# otherwise we need more advanced replacement or imputation mechanisms
# or drop the variable that has the misssings

# list rows of data that have missing values
#length(which(!complete.cases(data)))

# transform target back to probablity needed for plots in run-recode
data_set$p_target <- as.numeric(data_set[[target_name]])-1

# create new dataset without missing data
#data_set <- na.omit(data_set)
data_set.na <- data_set
data_set.imp <- na.roughfix(data_set) 

# impute using rfImpute
# use subset logical vector
# set.seed(123)
# lv <- as.logical(rbinom(nrow(data_set),1,0.05))
# data_set.imp <- rfImpute(churn_201305 ~ ., data_set, ntree=50, nodesize = 150, subset=lv )

# replace data with imputed in set 
data_set <- data_set.imp

## @knitr raw_pred_cap
# kendall tau over all predictors
# somers Dxy by Frank Ahrrell
library(Hmisc)

# method still slow , sampling needed
ssize <- 10 # in percent of dataset
n <- round(nrow(data_set)*ssize/100)
s_data_set <- data_set[sample(nrow(data_set), size=n), ]

# tijdelijk alleen eerste 45 vars
#s_data_set <- s_data_set[-c(45:145)] 

# create indices for all colums we want to do calculations
drops <- c("carid",target_name, "p_target")
idx <- which(!(names(s_data_set) %in% drops))

# function to calc correlation measure
myCorMeasures <- function(i=1, target=target_name,df=data_set) {
result <- cor.test(xtfrm(df[, i]), xtfrm(df[, target]), alternative="two.sided",method="kendall")$estimate
if(is.na(result)){
  result <- 0
  names(result) <- "tau"
}
return(result)
}

# somers Dxy
mySomersDxy <- function(i=1, target=target_name,df=data_set) {
  # TODO recode categoricals properly
  # TODO get C area under curve
  # result is a vector not a dataframe so use [""] to access attributes
  Dxy <- somers2(as.numeric(df[, i]), as.numeric(df[, target])-1)["Dxy"]
  C <- somers2(as.numeric(df[, i]), as.numeric(df[, target])-1)["C"]
  return(Dxy)
}

# todo add gini and other quality measures somers Dxy

# list of correlations of variables to target
correlation.Tau <- lapply(idx,myCorMeasures,df=s_data_set)
correlation.Dxy <- lapply(idx,mySomersDxy,df=s_data_set)

# make a numeric vector
nTau <- as.numeric(correlation.Tau)
nDxy <- as.numeric(correlation.Dxy)

# names
name <- names(data_set[,idx])
t <- data.frame(name,nTau,nDxy)
# sort correlation ascending 
t_sorted <- t[with(t, order(nTau)), ]

#digits(xt) <- c(0,2,4)
names(t_sorted) <- c('variable','Kendalls Tau','Somers Dxy')
row.names(t_sorted) <- NULL

library(pander)
panderOptions("table.style" , "rmarkdown")
panderOptions("table.split.table" , Inf) # avoid to split the tables

pander(t_sorted, caption = "Rank correlation measures!")

## @knitr run-recode

out = NULL
for (i in c(1:n_vars)) {
  print(c(i," from ",n_vars),quote=FALSE)
  out = c(out, knit_child('dp-recode.Rmd'))
}

## @knitr cluster

num_var_names <- names(data_set[sapply(data_set, is.numeric)])

# Hierarchical Variable Correlation 
# Generate the correlations (numerics only).

cc <- cor(data_set[,num_var_names], use="pairwise", method="pearson")

# Generate hierarchical cluster of variables.
hc <- hclust(dist(cc), method="average")

# Generate the dendrogram.
dn <- as.dendrogram(hc)

# Now draw the dendrogram.
op <- par(mar = c(3, 4, 3, 2.29))
plot(dn, horiz = TRUE, nodePar = list(col = 3:2, cex = c(2.0, 0.75), pch = 21:22, bg=  c("light blue", "pink"), lab.cex = 0.75, lab.col = "tomato"), edgePar = list(col = "gray", lwd = 2), xlab="Height")
title(main="Variable Correlation Clusters
 data using Pearson")
par(op)


## @knitr save-data
# remove p_target
data_set$p_target <- NULL

#datasetName = "../data/data-analysis.tab"
datasetName = "../data/model-set.Rdata"

#write.table(data_set,file = datasetName, sep = "\t", row.names=FALSE, quote = FALSE)

# alternative is to save R object in .Rdata format
save(data_set, file = datasetName)

## @knitr never

# test recoding and binning
#load tree package
library(rpart)
fit1<-rpart(churn_201305~,data=data_set,parms=list(prior=c(.95,.05)),maxdepth=3,cp=.001,method="class",x = TRUE,y = TRUE)
par(mfrow = c(1,1), xpd = NA)
plot(fit1);text(fit1,cex=0.5);
printcp(fit1)
plotcp(fit1)

fit1$cptable[which.min(fit1$cptable[,"xerror"]),"CP"]

# prune the tree 
pfit1 <- prune(fit1, cp = fit1$cptable[which.min(fit1$cptable[,"xerror"]),"CP"])
pfit1

library(randomForest)

arf<-randomForest(target~age,data=data_set,importance=TRUE,proximity=TRUE,ntree=50, keep.forest=TRUE)
#plot variable importance
varImpPlot(arf)

#conditional inference trees corrects for known biases in chaid and cart
library(party)
data_set$outcome <- as.factor(data_set$target)
data_set$target <- NULL
cfit2 <- ctree(outcome~age+income+gender,data=data_set, control = ctree_control( mincriterion = 0.6))
plot(cfit2);
table(predict(cfit1), data_set$taget)

irisct <- ctree(Species ~ .,data = iris)
irisct
plot(irisct)
table(predict(irisct), iris$Species)

hist(data_set$age, breaks = 5)