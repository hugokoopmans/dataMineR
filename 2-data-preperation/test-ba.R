library(plyr)
# bin tests r20112010mndbedrag
bin_r2011mb <-cut(train$r20112010mndbedrag, unique(quantile(train$r20112010mndbedrag,probs = seq(0, 1, 0.1))))
br <- unique(quantile(train$r20112010mndbedrag,probs = seq(0, 1, 0.1)))

#transform traget back to probablity
data$p_target <- as.numeric(data$target)
# create bin stats
bin_r2011mb.stats <- ddply(train,~ bin_r2011mb,summarise,sum=sum(p),mean=mean(p),sd=sd(p))
bin_stats <- ddply(data,~ gender,summarise,sum=sum(p_target),mean=mean(p_target),sd=sd(p_target))

barplot(height=bin_stats$mean,names.arg = bin_stats$gender)

library(ggplot2)

bin_stats <- ddply(data,~ gender,summarise,sum=sum(p_target),mean=mean(p_target),sd=sd(p_target))


d1 <- ddply(data,~ gender,summarise,y=sum(p_target))
d2 <- ddply(data,~ gender,summarise,y=mean(p_target))

d1$panel <- "volume"
d2$panel <- "p(target)"

ggplot(data=d1, aes(x=gender, y=y)) + geom_bar(stat = "identity") + geom_point()
ggplot(data=d2, aes(x=gender, y=y)) + geom_point()

d <- rbind(d1, d2)
p <- ggplot(data = d, mapping = aes(x = gender, y = y))
p <- p + facet_grid(panel ~ ., scale = "free")
p <- p + layer(data = d1, geom = c( "bar"), stat = "identity")
p <- p + layer(data = d2, geom = c( "point"), stat = "identity")
p

# Separate regressions
qplot(r20112010mndbedrag,p, data=train, geom=c("point", "smooth"), 
      #      method="lm", formula=y~x,  
      main="Regression of r20112010mndbedrag", 
      xlab="r20112010mndbedrag", ylab="P(target)")

# Kernel density plots for mpg
# grouped by number of gears (indicated by color)
qplot(r20112010mndbedrag, data=train, geom="density", fill=target, alpha=I(.5), 
      main="Distribution of Target", xlab="r20112010mndbedrag", 
      ylab="Density")