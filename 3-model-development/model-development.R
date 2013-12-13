# model development

# knitr uses Rmd file location as working directory
# if we run script from Rstudio we need to put the right working dir
setwd("~/r-studio/dataMineR/3-model-development")

# target_name
target_name <- "target"
# scoreband bins
bins <- 20
# proportion used for training set
training_proportion <- 0.7


## @knitr read_data

#### parameters ####
# filename
#filename <- "../data/data-analysis.tab"
filename <- "../data/model-set.Rdata"

# read dataframe from tab delimets file
#data_set <- read.delim(filename)
load(filename)

# remove p_target
data_set$p_target <- NULL

# determine number of rows and colums in dataframe
rows <- nrow(data_set)
colums <- ncol(data_set)

## @knitr validation-setup

# split into test and training set
# training_proportion set in first chunk generic parameters default 0.7
smp_size <- floor(training_proportion * nrow(data_set))

## set the seed to make your partition reproductible
set.seed(456)
train_ind <- sample(seq_len(nrow(data_set)), size = smp_size)

train_set <- data_set[train_ind, ]
test_set <- data_set[-train_ind, ]

## @knitr save-test-set-data

datasetName = "../data/test-set.Rdata"
save(test_set, file = datasetName)

## @knitr feature-selection

library(randomForest)

#data_set <- na.roughfix(data_set)

# use subset so we do NOT use all data
sub_size <- floor(0.1 * nrow(train_set))
subset_ind <- sample(seq_len(nrow(train_set)), size = sub_size)

base.formula <- as.formula(paste(target_name,"~ ."))
#environment(base.formula) <- environment()

model.rf <- randomForest(base.formula, train_set, nodesize = 150, subset=subset_ind, cutoff=c(0.8,0.2))
# print(model.rf)
imp <- importance(model.rf)
imp.df <- as.data.frame(imp)
imp.sorted <- imp.df[order(-imp.df[,1]), , drop = FALSE]

library(pander)
panderOptions("table.style" , "rmarkdown")
panderOptions("table.split.table" , Inf) # avoid to split the tables

# table with all variables
pander(imp.sorted)

## @knitr remove-unimportant

# remove unimportant vars
unimp <- imp.sorted[imp.sorted[1]<1, ,drop=FALSE]

# table with unimportant variables
pander(unimp)

# we do not need this as we are not able to score the full models later on
## drop unimportant vars from data_set
#drops <- row.names(unimp)
#train_set <- train_set[,!(names(train_set) %in% drops)]

## @knitr simple-tree

# build simple trees on most important variables
# load tree package
library(rpart) 

# create formula function dynamically using
simple.tree.formula <- as.formula(paste(target_name,"~",paste(row.names(imp.sorted)[1:2],collapse="+")))
# extract prior from base rate of target var
base.rate <- mean(as.numeric(data_set[[target_name]])-1)
class.prior <- c(1-base.rate,base.rate)
model.simple.tree <- rpart(simple.tree.formula,data=train_set,parms=list(prior=class.prior),maxdepth=8,cp=.000001,method="class",x = TRUE,y = TRUE)

## @knitr plot-simple-tree
library(rpart.plot)

# plot the tree using the heat functionand the custom split function defined in dataminer source file
heat.tree(model.simple.tree, type=0, extra=7, under=T, varlen=0, prefix="churn\n", faclen=0,
          split.fun=split.fun, fallen.leaves=F,branch.type=5,leaf.round=1)

## @knitr plot-cp

# build bigger tree to show hw cp pruning works
# create formula function dynamically using
tree.formula <- as.formula(paste(target_name,"~",paste(row.names(imp.sorted)[1:10],collapse="+")))
# extract prior from base rate of target var
base.rate <- mean(as.numeric(data_set[[target_name]])-1)
class.prior <- c(1-base.rate,base.rate)
model.tree <- rpart(tree.formula,data=train_set,parms=list(prior=class.prior),maxdepth=12,cp=.00001,method="class",x = TRUE,y = TRUE)

plotcp(model.tree)

## @knitr prune-tree

# find cp value to using in pruning
cp.optimal <- model.tree$cptable[which.min(model.tree$cptable[,"xerror"]),"CP"]

# prune the tree 
model.tree.p <- prune(model.tree, cp = cp.optimal)

plot(model.tree)
plot(model.tree.p)

## @knitr rf-stratified

library(randomForest)
# random forests work better on stratified datasets
library(sampling)
# create indices to be used as strata in RF
s = strata(train_set,stratanames = target_name, size = c(5000,5000))

### stratified model all inputs ###
# model formulation 
rf.all.formula <- as.formula(paste(target_name,"~."))

# build rf model using the above stratum
model.rf.s <- randomForest(rf.all.formula, train_set, nodesize = 50, subset=s$ID_unit)

# plot variable importance
varImpPlot(model.rf.s)

# use top10 only variables from model above
imp.s <- importance(model.rf.s)
imp.s.df <- as.data.frame(imp.s)
imp.s.sorted <- imp.s.df[order(-imp.s.df[,1]), , drop = FALSE]

### stratified use only top 10 from stratified model above ###
# model formulation for stratified model top10
rf.t10.formula <- as.formula(paste(target_name,"~",paste(row.names(imp.s.sorted)[1:10],collapse="+")))

# build rf model using the above stratum
model.rf.s.t10 <- randomForest(rf.t10.formula, train_set, nodesize = 50, subset=s$ID_unit)


## @knitr rf-parallel

### rf on big/all training set ###
# use parallel foreach
library(foreach)

library(doMC)
registerDoMC(4)  #change the 2 to your number of CPU cores 
# info on parrallell backend
getDoParName()
getDoParWorkers()

# use strata to sample whole dataset
library(sampling)

s1 = strata(train_set,stratanames = target_name, size = c(10000,10000))
s2 = strata(train_set,stratanames = target_name, size = c(10000,10000))
s3 = strata(train_set,stratanames = target_name, size = c(10000,10000))
s4 = strata(train_set,stratanames = target_name, size = c(10000,10000))

s_list <- list(s1$ID_unit, s2$ID_unit, s3$ID_unit, s4$ID_unit)

# function formula
rf.all.formula <- as.formula(paste(target_name,"~."))

library(randomForest)

# build rf with dopar
model.rf.s.b2 <- foreach(subset=s_list, .combine='combine', .multicombine=TRUE, .packages='randomForest') %dopar%{
  environment(rf.all.formula) <- environment()
  randomForest(rf.all.formula, train_set, ntree=1000, nodesize = 50, subset=subset)
}
  
# use top10 only variables from model above
imp.s.b <- importance(model.rf.s.b2)
imp.s.b.df <- as.data.frame(imp.s.b)
imp.s.b.sorted <- imp.s.b.df[order(-imp.s.b.df[,1]), , drop = FALSE]

# build rf model using the above stratum
rf.b.t10.formula <- as.formula(paste(target_name,"~",paste(row.names(imp.s.b.sorted)[1:10],collapse="+")))

#model.rf.s.b.t10 <- randomForest(rf.formula, train_set, nodesize = 50, subset=s$ID_unit)

# build rf with dopar
# rf.formula seems not to work in for each
model.rf.s.b2.t10 <- foreach(subset=s_list, .combine='combine', .multicombine=TRUE, .packages='randomForest') %dopar% {
  environment(rf.b.t10.formula) <- environment()
  randomForest(rf.b.t10.formula, train_set , ntree=1000, nodesize = 50, subset=subset)
}

## @knitr eval-on-training

# model list depends on models created in previous chunks
model_list <- list( model.simple.tree, model.tree, model.tree.p, model.rf, model.rf.s, model.rf.s.b2, model.rf.s.b2.t10)
model_names <- c("model.simple.tree","model.tree","model.tree.p","model.rf","model.rf.s","model.rf.s.b2","model.rf.s.b2.t10")
model_descript <- c("Decision tree two variables","Decision tree all variables","Decision tree Pruned","Random Forest","Random Forest on stratiefied dataset","Random Forest on all data", "Random Forest on best 10 variables")

# make sure the target has the right order(equivalent with 0 and 1)
train_set[[target_name]] <- ordered(train_set[[target_name]])

prfList <- lapply(model_list,calcPerformance, data_set = train_set)

## @knitr plot-roc

plotROC(prfList,model_names[1:7])

## @knitr score-table
model_id <- 5

#score_results <- score_table(model=unlist(model_list[model_id]),data_set=train_set, bins=20)
score_results <- score_table(model=model_list[[model_id]],data_set=train_set, bins=10)

# print table via pander
pander(score_results$scoretable)


## @knitr save-models

# create table to document model list

model_table <- cbind(model_names,model_descript)
# print table via pander
pander(model_names)
# save models
modelStoreName = "../data/modelStore.Rdata"
save(model_list, model_names, model_descript, file = modelStoreName)
  



