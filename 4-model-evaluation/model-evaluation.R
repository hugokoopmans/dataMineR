# model evaluation

# knitr uses Rmd file location as working directory
# if we run script from Rstudio we need to put the right working dir

# standalone parameters:
setwd("~/r-studio/NLE/4-model-evaluation")
# target name
target_name <- "churn_201305"
# source dataMineR functions
source("./dataminer.R")

## @knitr read_data

#### parameters ####
# filename
#filename <- "../data/data-analysis.tab"

datasetname <- "../data/test-set.Rdata"

# read dataframe from tab delimets file
#data_set <- read.delim(filename)
load(datasetname)

# determine number of rows and colums in dataframe
rows <- nrow(test_set)
colums <- ncol(test_set)

## @knitr evaluation-setup

# load model store
modelstorename = "../data/modelStore.Rdata"

load(modelstorename)

n_models <- length(model_list)

# TODO create table of different models available for evaluation

# # list of models to be evaluated
# model_list <- list( model.simple.tree, model.tree, model.tree.p, model.rf, model.rf.s,model.rf.s.b2)
# model_names <- c("model.simple.tree","model.tree","model.tree.p","model.rf","model.rf.s","model.rf.s.b2")

## @knitr model-evaluation

# make sure the target has the right order(equivalent with 0 and 1)
test_set[[target_name]] <- ordered(test_set[[target_name]])

require(randomForest)

## @knitr roc-curves

prfList <- lapply(model_list,calcPerformance, data_set = test_set)
plotROC(prfList,model_names[1:n_models])

## @knitr lift-curves

plotLift(prfList[2:6],model_names[1:n_models])

## @knitr gains-charts

plotGains(prfList,model_names[1:n_models])

## @knitr score-table
require(randomForest)

model_id <- 5
score_results <- score_table(model=model_list[[model_id]],data_set=test_set, bins=20)

# setup pander
library(pander)
panderOptions("table.style" , "rmarkdown")
panderOptions("table.split.table" , Inf) # avoid to split the tables

# print table via pander
pander(score_results$scoretable)

## @knitr run-never

# combine score with testset
# use merge by rownames
result_set <- merge(test_set,df.score, by="row.names")

datasetName = "./data/result-set.Rdata"
save(result_set, file = datasetName)

# validate scorebands on test set
# select best model and calculate 20 bins
result.rf.s.b2 <- predict(model.rf.s.b2,test_set,type = "prob")
# dataframe churn prob and testset churnflag
df.r <- as.data.frame(cbind(as.numeric(test_set$churn_201305)-1,result.rf.s.b2[,2]))
names(df.r) <- c("Churn","Pchurn")
# order to prob
df.r <- df.r[order(df.r$Pchurn),]
# create bins
df.r$bins <- with(df.r, cut(Pchurn, breaks=quantile(Pchurn, probs=seq(0,1, by=0.05)), include.lowest=TRUE, labels=1:20))
df.r$bins2 <- with(df.r, cut(Pchurn, breaks=quantile(Pchurn, probs=seq(0,1, by=0.05)), include.lowest=TRUE))

# table
t <- table(df.r$bins2,df.r$Churn)
df.t <- as.data.frame.matrix(t)
df.t$pac <- tapply(df.r$Churn, df.r$bins, mean)

# crosstable
library(gmodels)
library(MASS)

# table
t <- table(data_set$prospectactieomschrijving,data_set$churn_201305)
tapply(data_set$prospectactieomschrijving,as.numeric(data_set$churn_201305), mean)

imp.sorted
mset <- data_set[rownames(imp.sorted)[1:10]]
mset$churn_201305 <- data_set$churn_201305
datasetName = "./data/top10modeldata.tab"
write.table(mset,file = datasetName, sep = "\t", row.names=FALSE, quote = FALSE)