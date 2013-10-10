FILE=datamineR-introduction
#PDFTEMPLATE=../templates/pdf/simple.tex
PDFTEMPLATE=../templates/pdf/extended.tex
# org 
OPT_PDF= -V numbersections=numbersections -V toc=toc -V documentclass=memoir -V fontsize=11pt -V toc-depth=2  
# simple 
#OPT_PDF= -V documentclass=memoir -V fontsize=11pt -V toc-depth=2  

# -F +implicit_header_references
# --variable documentclass=tufte-handout 
# options cut: 

md: $(FILE).Rmd
	Rscript -e "library(knitr); knit('$(FILE).Rmd')"

html:$(FILE).md
	pandoc $(FILE).md -o $(FILE).html

spdf: $(FILE).md
	pandoc $(FILE).md -o $(FILE).pdf --template mytemplate.tex --highlight-style tango

tex: $(FILE).md 
	pandoc $(FILE).md -o $(FILE).tex --template $(PDFTEMPLATE) # mytemplate.tex

pdf: $(FILE).md
	pandoc $(FILE).md -o $(FILE).pdf --template $(PDFTEMPLATE) --listings $(OPT_PDF)
