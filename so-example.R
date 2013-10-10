# some data
x <- runif(1000)
x2 <- rnorm(1000)
y <- data.frame(x,x2)
# we want to bin the dataframe y acording to values in x into b bins
b = 10
bins=10

# we create breaks in several ways
breaks=unique(quantile(x, probs=seq.int(0,1, by=1/b)))
breaks=unique(quantile(y$x, probs=seq.int(0,1, length.out=b+1)))

# now to question
# this wokrs
y$b <- with(y, cut(x, breaks=unique(quantile(x, probs=seq.int(0,1, length.out=11))), include.lowest=TRUE))
table(y$b)
# this works too
y$b2 <- with(y, cut(x, breaks=unique(quantile(x, probs=seq.int(0,1, length.out=(bins+1)))), include.lowest=TRUE))
table(y$b2)
# this does not work
brks=unique(quantile(x, probs=seq.int(0,1, length.out=(b + 1))))
y$b3 <- with(y, cut(x, breaks=brks, include.lowest=TRUE))


y$b <- NULL
y$b3 <- with(y, cut(x, breaks=unique(quantile(x, probs=seq.int(0,1, length.out=(b+1)))), include.lowest=TRUE))

# seems the word "bins"is used for something else then holding a number?

