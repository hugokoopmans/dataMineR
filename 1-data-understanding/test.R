samplesize <-100
g1 <- gl(2,samplesize/2,labels=c("V","M"))
g2 <- gl(3,samplesize/3,labels=c("V","M","U"))
m <- 2
d <- data.frame(g1,g2)
l <-  sapply(d,nlevels)
cd <- d[,l <= m, drop=FALSE]
names(cd)