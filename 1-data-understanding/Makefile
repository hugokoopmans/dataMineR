FILE=Data-Analysis-Report
PDFTEMPLATE=../templates/pdf/extended.tex
OPT_PDF=--variable numbersections --toc --variable toc-depth=2 --variable documentclass=memoir --variable fontsize=11pt 
# -F +implicit_header_references
# --variable documentclass=tufte-handout 
# options cut: 

md: $(FILE).Rmd
	../bin/k $(FILE).Rmd

html:$(FILE).md
	pandoc $(FILE).md -s -c ../templates/html/pandoc.css --highlight-style pygments --mathjax -o $(FILE).html

spdf: $(FILE).md $(FILE).Rmd
	pandoc $(FILE).md -o $(FILE).pdf --template mytemplate.tex --highlight-style tango

tex: $(FILE).md 
	pandoc $(FILE).md -o $(FILE).tex --template $(PDFTEMPLATE) -o $(FILE).tex

pdf: $(FILE).md $(FILE).Rmd
	pandoc $(FILE).md -o $(FILE).pdf --template $(PDFTEMPLATE) --listings $(OPT_PDF)
