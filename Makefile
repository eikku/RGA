PACKAGE = $(shell grep '^Package: ' DESCRIPTION | awk '{ print $$2 }')
VERSION = $(shell grep '^Version: ' DESCRIPTION | awk '{ print $$2 }')
PARENTDIR = ..
TARBALL = $(PACKAGE)_$(VERSION).tar.gz
TARBALL_LOC = $(PARENTDIR)/$(TARBALL)
CHECKDIR = $(PARENTDIR)/$(PACKAGE).Rcheck

all: data doc locales check install

deps:
	Rscript -e 'devtools::install_deps()'

data:
	Rscript tools/get-data.R 2>&1 >/dev/null

doc:
	Rscript tools/get-docs.R 2>&1 >/dev/null
	Rscript -e 'devtools::document(roclets=c("rd", "collate", "namespace", "vignette"))'

check:
	Rscript -e 'devtools::check(check_version = TRUE, force_suggests = TRUE)'

test:
	Rscript -e 'devtools::test()'

install:
	Rscript -e 'devtools::install()'

build:
	Rscript -e 'devtools::build()'

build-win:
	Rscript -e 'devtools::build_win()'

vignettes:
	Rscript -e 'devtools::build_vignettes()'

submit:
	Rscript -e 'devtools::submit_cran()'

clean:
	rm -f $(TARBALL_LOC)
	rm -rf $(CHECKDIR)

.PHONY: build doc data vignettes
