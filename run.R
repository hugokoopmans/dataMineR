#install.packages("pander")
library(pander)
library(knitr)

setwd("/Users/toni/Dropbox/_Scratch/github/dataMineR")      # Change if necessary

# Using knitr with pander
# Pander should take care of formatting tables, lists, etc.
# Knitr is about converting Rmd to executed code
# Pander normally uses brew, but knitr is more recent and allows for multiline code
# But then, we need to override the 'print' call


setwd("/Users/toni/Dropbox/_Scratch/github/dataMineR/0-datamineR-introduction/")      # Change if necessary

knit2html("datamineR-intro.Rmd")
Pandoc.convert("datamineR-intro.md",format="html")


Pandoc.brew("datamineR-intro.md")

methods(pander)

Pandoc.convert("datamineR-intro.md",format="pdf")



library(knitr)
library(markdown)
library(hwriter)
install.packages("hwriter")

knit("test.Rmd")
Pandoc.convert("test.md",format="pdf")




