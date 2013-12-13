# datamineR functions

# required libraries

#require(ROCR)
#require(rpart)
#require(rpart.plot)        # Enhanced tree plots


#_______________________________________________________________________
# plot custom tree
# functions : split.fun
#             heat.tree
#_______________________________________________________________________

# plot tree using prp

# split function
split.fun <- function(x, labs, digits, varlen, faclen){
  #gsub("[aouijeyAOUIJEY]","",labs)
  # keep first 25 characters of labs
  labs <- substr(labs,0,25)
  # add a newline after = 
  gsub("[=]", "=\n", labs)
}

# heat colors in tree
heat.tree <- function(tree, ...) { # dots args passed to prp
  require(rpart.plot)
  y <- tree$frame$yval2[,5]
  max <- max(y)
  min <- min(y)
  cols <- rainbow(length(y), start=0, end=.33,alpha=0.8)[
    # colors ranked like -y red(0) equivalent to high prob. of churn
    rank(-y)]
  # color boxes only
  #prp(tree, branch.col=cols, box.col=cols, ...)
  prp(tree, box.col=cols, ...)
}

#_______________________________________________________________________
# Calculate preformance of models in model list on dataset
# functions : calcPerformance
#             
#_______________________________________________________________________
# Plot the performance of the model applied to the evaluation set as
# an ROC curve.

calcPerformance <- function (model=model,data_set=data_set) {
  suppressPackageStartupMessages(require(randomForest))
  # seems ROCR messages ruin markdown in chunk
  suppressPackageStartupMessages(require(ROCR))
  # probability
  prb <- predict(model,data_set,type = "prob")
  # prediction
  # target label has to be in right order!!!!
  prd <- prediction(prb[,2], data_set[[target_name]])
  # performance measures
  prf <- performance(prd,"tpr","fpr")
  gns <- performance(prd,"tpr","rpp")
  lft <- performance(prd,"lift","rpp")
  auc <- performance(prd,"auc")
  return(list("prf"= prf, "lft"=lft, "gns"=gns, "auc" = auc@y.values))
}

# plot roc curves

plotROC <- function (prfList, m_names=model_names) {
  #intercept at 0,0 and max of graph also adjusted
  par(xaxs="i", yaxs="i")
  # color pallette
  lineColour <- rainbow(length(m_names))
  plot(prfList[[1]]$prf, main="ROC curve", col = lineColour[1])
  # dotted diagonal line 
  abline(0,1,lty=2,col = "gray10")
  for (i in 2:length(prfList) ){
    plot(prfList[[i]]$prf, add = TRUE, col = lineColour[i])
  }  
  # legend
  # combine names and auc in one legend
  for (i in 1:length(m_names)){
    m_names[i] <- paste(as.character(m_names[i])," : ",sprintf("%.3f",as.numeric(prfList[[i]]$auc)))
  }
  # legend
  legend("bottomright",legend=m_names,lty=c(1,1),col = lineColour,pch=21, cex=0.5)
}

# plot lift curves

plotLift <- function (prfList, m_names=model_names) {
  #intercept at 0,0 and max of graph also adjusted
  par(xaxs="i", yaxs="i")
  # color pallette
  lineColour <- rainbow(length(model_names))
  plot(prfList[[1]]$lft, main="Lift curve", col = lineColour[1], xlab="Proportion of the base",ylim=c(0.0,5.0))
  abline(1,0,lty=2,col = "gray10")
  for (i in 2:length(prfList) ){
    plot(prfList[[i]]$lft, add = TRUE, col = lineColour[i])
  }  
  # legend
  #plot legend
  legend("topright",legend=m_names,lty=c(1,1),col = lineColour,pch=21, cex=0.5)
}

# plot gains chart

plotGains <- function (prfList, m_names=model_names) {
  #intercept at 0,0 and max of graph also adjusted
  par(xaxs="i", yaxs="i")
  # color pallette
  lineColour <- rainbow(length(m_names))
  plot(prfList[[1]]$gns, main="Gains Chart", col = lineColour[1], xlab="Proportion of the base", ylab="Proportion of Churners")
  # dotted diagonal line 
  abline(0,1,lty=2,col = "gray10")
  for (i in 2:length(prfList) ){
    plot(prfList[[i]]$gns, add = TRUE, col = lineColour[i])
  }  
  # legend
  # combine names and auc in one legend
  #   for (i in 1:length(m_names)){
  #     m_names[i] <- paste(as.character(m_names[i])," : ",sprintf("%.3f",as.numeric(prfList[[i]]$auc)))
  #   }
  # plot perfect model
  abline(0,1/base.rate,lty=3, col = "red")
  
  legend("bottomright",legend=m_names,lty=c(1,1),col = lineColour,pch=21, cex=0.5)
}

#_______________________________________________________________________
# Calculate score table from scored dataset
# functions : score_table(bins = 20, data_set = data_set, model = model)
# TODO > ad targetname
#_______________________________________________________________________

# 
score_table <- function (bins = 20, data_set = data_set, model = model) {
  require(randomForest)
  require(rpart)
  # calculate scorebands on dataset
  # select best model and calculate 20 bins
  score.model <- predict(model,data_set,type = "prob")
  # dataframe churn prob and testset churnflag
  df.score <- as.data.frame(cbind(as.numeric(data_set$target)-1,score.model[,2]))
  names(df.score) <- c("Churn","Pchurn")
  # order to prob
  df.score <- df.score[order(df.score$Pchurn),]
  # create bins
  # if bins are not unique make it so
  # consequence is we miss nice labels
  # TODO find the max number of bins for which breaks are unique
  if (length(unique(quantile(df.score$Pchurn, probs=seq(0,1, by=1/bins)))) == bins+1)
    df.score$bins <- with(df.score, cut(Pchurn, breaks=unique(quantile(Pchurn, probs=seq(0,1, by=1/bins))), include.lowest=TRUE, labels=1:bins))
  else
    df.score$bins <- with(df.score, cut(Pchurn, breaks=unique(quantile(Pchurn, probs=seq(0,1, by=1/bins))), include.lowest=TRUE))
  
  # create score table
  t.score <- table(df.score$bins,df.score$Churn)
  # test for goodness of fit
  # hypothesis is that the proportion of churners is different from the proportion of non churners
  # if we use the modeled probablity to create the bins
  chisq.test(t.score)
  # transform to data frame
  df.score.table <- as.data.frame.matrix(t.score)
  names(df.score.table) <- c("No","Yes")
  df.score.table$n <- df.score.table$Yes + df.score.table$No
  df.score.table$p <- tapply(df.score$Churn, df.score$bins, mean)
  # TODO add significance to bands
  # binom.test()
  df.score.table$p.lcl <- apply(df.score.table, 1, function(x)  binom.test(x[2],x[3])$conf.int[1] )
  df.score.table$p.ucl <- apply(df.score.table, 1, function(x)  binom.test(x[2],x[3])$conf.int[2] )
  
  return (list("score" = df.score,"scoretable" = df.score.table))
}