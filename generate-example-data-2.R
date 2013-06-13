# generates example data to be used in the dataMineR project
# this dataset is to be used as an example to see if we can find the model back we put in here.

samplesize <- 5000

#income lognormal
modaal <- 33000
income <- modaal*rlnorm(samplesize,0,0.25)

# age
avg_age <- 40
age <- rnorm(samplesize,avg_age,20)
# cap minimum
age <- ifelse(age<18,18+abs(age-18),age)
# cap maximum
age <- ifelse(age>85,85-abs(age-85),age)
# gender
gender <- gl(2,samplesize/2,labels=c("F","M"))

#normalize
n_income <- scale(income,TRUE,TRUE)
n_age <- scale(age,TRUE,TRUE)
n_gender <- scale(as.numeric(gender))

# model parameters
# real world
b0 <- 3.5
b1 <- 0.5
b2 <- 0.2
b3 <- -0.3

#real world model
real_world <- b0 + b1*n_age + b2*n_income + b3*n_gender#+ error_term_b

# calc logit probability
p_real <- exp(real_world)/(1+exp(real_world))
goodrate <- mean(p_real)

# good bad model
GB <- function(x) {sample(c(1.0,0.0),size = 1, replace=TRUE,prob=c(x,1-x))}

# create outcome y
y <- sapply(p_real,GB)

# sanity check , we should find the model parameters we just put in to generate th outcome
mylogit <- glm(y~n_age+n_income+n_gender, family=binomial(link="logit"), na.action=na.pass)

summary(mylogit)
# ok we find the b0, b1 and b2

# how sure are we about the parameters given the 10000 sample?
confint(mylogit)

p_y <- mylogit$fit

data <- data.frame(age,income,gender,p_real,p_y,y)

# case ID
rowID <- as.numeric(row.names(data))

data$caseID <- rowID

# export to flat file
write.table(data, file="./data/data-simple-example.tab",sep="\t",row.names = FALSE)
