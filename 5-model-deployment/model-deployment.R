# model deployment

# connect to postgresDB
library(RPostgreSQL)

## loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")

## Open a connection
con <- dbConnect(drv, user="NLE", password = "NLE", dbname="NLE", host="localhost")

## Submits a statement
rs <- dbSendQuery(con, "select * from testtabel")

## fetch all elements from the result set
f <- fetch(rs,n=-1)

# write bakc as table
dbWriteTable(con, "temp_table_data", f)
dbWriteTable(con, "test_set", test_set)


## Submit and execute the query
dbGetQuery(con, "select * from R_packages")

## Closes the connection
dbDisconnect(con)

## Frees all the resources on the driver
dbUnloadDriver(drv)