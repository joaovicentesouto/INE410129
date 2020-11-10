PDFLATEX=pdflatex
BIBTEX=bibtex
MAKEINDEX=makeindex
LTX=$(PDFLATEX) -shell-escape -interaction=nonstopmode
XINDY=xindy
INKS=inkscape
GIT=git
PDFINFO=pdfinfo
PODOFOBOX=podofobox
GNUPLOT=gnuplot


###################################################
# Compute some target enumerations                #
###################################################

srcs=$(wildcard *.tex) $(wildcard *.bib)
svgs=$(wildcard imgs/svgs/*.svg)
frames=$(foreach k,1 2 3 4 5,imgs/processor-trend-$k.pdf) $(foreach k,1 2 3,imgs/lazy-transfer-$k.pdf) $(foreach k,1 2 3 4 5 6 7 8 9 10,imgs/task-abstraction-$k.pdf)
pdfs=$(svgs:.svg=.pdf) 
others=$(wildcard imgs/others/*.pdf) $(wildcard imgs/others/*.jpg) $(wildcard imgs/others/*.png)

###################################################
# phony targets                                   #
###################################################

all: imgs main.robust.pdf clean-latex

imgs: $(pdfs)
	cp $(pdfs) imgs
	cp $(others) imgs

.PHONY: all imgs clean

clean-main:
	rm -fr main.pdf main.robust.pdf

clean-latex:
	rm -fr *.64 main-logo.pdf _minted-* *.aux *.bbl *.blg *.brf *.out *.synctex.gz *.log *.idx *.ilg *.ind *.lof *.lot *.lol *.loalgorithm *.glsdefs *.xdy *.toc *.acn *.glo *.ist *-*.pdf *-*.jpg *-*.png *.nav *.snm *.vrb *.prv _region*  *~ auto; 

clean-imgs:
	rm -fr  imgs/*.pdf imgs/*.jpg imgs/*.png imgs/svgs/*.pdf {imgs,plots}/*-eps-converted-to.pdf; 

clean: clean-main clean-latex clean-imgs

###################################################
# SVG -> PDF conversion                           #
###################################################

INKS_VER:=$(shell (inkscape --version 2>&1 | grep -E 'Inkscape [1-9]' &>/dev/null) && echo 1 || echo 0)
INKSCAPE=$(INKS) $(if $(subst 0,,$(INKS_VER)),,-z)
define inkscape2pdf
	$(INKSCAPE) $(3) $(if $(subst 0,,$(INKS_VER)),--export-filename,-A)=$(2) $(1) 
endef

# directly convert a SVG to PDF. The SVG's contents will be cropped to the page
imgs/%.pdf: imgs/%.svg
	$(call inkscape2pdf,$<,$@,-C)

#Possible bug: inkscape -z -D -i gSlide1 -A=out.pdf in.svg
#Workaround: generate a pdf of the whole drawing (-D, beyond page borders); get bottom:left:width:height of object; convert px to PostScript pts; crop from the pdf
#Quirk: inkscape -Y has top-left corner of page at origin
define svg2pdf
	$(call inkscape2pdf,$(1).svg,$(3).tmp.pdf,-D)
	PTS=$$($(PDFINFO) $(3).tmp.pdf | grep 'Page size' | sed 's/[^0-9]*\([0-9]*\.[0-9]*\)[^0-9].*/\1/'); \
	IW=$$($(INKSCAPE) --query-width $(1).svg); \
	FAC=$$(echo "scale=3; 100 * $$PTS / $$IW" | bc); \
	X=$$(awk "BEGIN {printf \"%.3f\", $$FAC * $$($(INKSCAPE) -I $(2) -X $(1).svg)}"); \
	Y=$$(awk "BEGIN {printf \"%.3f\", $$FAC * (-1)*($$($(INKSCAPE) -I $(2) -Y $(1).svg))}"); \
	W=$$(awk "BEGIN {printf \"%.3f\", $$FAC * $$($(INKSCAPE) -I $(2) -W $(1).svg)}"); \
	H=$$(awk "BEGIN {printf \"%.3f\", $$FAC * $$($(INKSCAPE) -I $(2) -H $(1).svg)}"); \
	$(PODOFOBOX) $(3).tmp.pdf $(3).pdf media $$X $$Y $$W $$H
	rm $(3).tmp.pdf
endef

###################################################
# Frane targets                                   #
###################################################

imgs/processor-trend-1.pdf: imgs/svgs/processor-trend.svg
	$(call svg2pdf,imgs/svgs/processor-trend,gSlide1,imgs/processor-trend-1)
imgs/processor-trend-2.pdf: imgs/svgs/processor-trend.svg
	$(call svg2pdf,imgs/svgs/processor-trend,gSlide2,imgs/processor-trend-2)
imgs/processor-trend-3.pdf: imgs/svgs/processor-trend.svg
	$(call svg2pdf,imgs/svgs/processor-trend,gSlide3,imgs/processor-trend-3)
imgs/processor-trend-4.pdf: imgs/svgs/processor-trend.svg
	$(call svg2pdf,imgs/svgs/processor-trend,gSlide4,imgs/processor-trend-4)
imgs/processor-trend-5.pdf: imgs/svgs/processor-trend.svg
	$(call svg2pdf,imgs/svgs/processor-trend,gSlide5,imgs/processor-trend-5)

imgs/lazy-transfer-1.pdf: imgs/svgs/lazy-transfer.svg
	$(call svg2pdf,imgs/svgs/lazy-transfer,gSlide1,imgs/lazy-transfer-1)
imgs/lazy-transfer-2.pdf: imgs/svgs/lazy-transfer.svg
	$(call svg2pdf,imgs/svgs/lazy-transfer,gSlide2,imgs/lazy-transfer-2)
imgs/lazy-transfer-3.pdf: imgs/svgs/lazy-transfer.svg
	$(call svg2pdf,imgs/svgs/lazy-transfer,gSlide3,imgs/lazy-transfer-3)

imgs/task-abstraction-1.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide1,imgs/task-abstraction-1)
imgs/task-abstraction-2.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide2,imgs/task-abstraction-2)
imgs/task-abstraction-3.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide3,imgs/task-abstraction-3)
imgs/task-abstraction-4.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide4,imgs/task-abstraction-4)
imgs/task-abstraction-5.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide5,imgs/task-abstraction-5)
imgs/task-abstraction-6.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide6,imgs/task-abstraction-6)
imgs/task-abstraction-7.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide7,imgs/task-abstraction-7)
imgs/task-abstraction-8.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide8,imgs/task-abstraction-8)
imgs/task-abstraction-9.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide9,imgs/task-abstraction-9)
imgs/task-abstraction-10.pdf: imgs/svgs/task-abstraction.svg
	$(call svg2pdf,imgs/svgs/task-abstraction,gSlide10,imgs/task-abstraction-10)

###################################################
# main targets                                    #
###################################################

main.aux: $(srcs) $(pdfs) $(frames) $(others)
	$(LTX) main.tex; $(LTX) main.tex || true

main.blg: main.aux $(srcs)
	$(BIBTEX) main.aux

main.pdf: $(srcs) main.aux main.blg
	$(LTX) main.tex; \
	$(LTX) main.tex || true

# Converts main.pdf to PDF version 1.4 and embedd all fonts
# This is required by IEEE (this is done by PDF Xpress) and Elsevier journals
main.robust.pdf: main.pdf
	gs -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dEmbedAllFonts=true -sOutputFile="$@" -f "$<" 
