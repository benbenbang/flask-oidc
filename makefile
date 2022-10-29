.EXPORT_ALL_VARIABLES:
# sphinx doc
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SPINXAUTODOC  ?= sphinx-apidoc
SOURCEDIR     = docs/source
BUILDDIR      = docs/build

# ------------------------------------
# Customized func / var define
# ------------------------------------

ifeq (,$(shell which poetry))
HAS_POETRY=False
else
HAS_POETRY=True
endif

# ------------------------------------
# Test
# ------------------------------------

.PHONY: unittests
## Run unittests
unittests:
	@-export COVERAGE_FILE=.coverage.unittests;\
	poetry run python -m pytest -k unittests --junitxml=unittests_junit_report.xml --cov --cov-config=tests/.coveragerc -vv

.PHONY: integrationtests
## Run integrationtests
integrationtests:
	@-export COVERAGE_FILE=.coverage.integrationtests;\
	poetry run python -m pytest -k integrationtests --junitxml=integrationtests_junit_report.xml --cov --cov-config=tests/.coveragerc -vv

.PHONY: sanitytests
## Run sanitytests
sanitytests:
	@poetry run python -m pytest -k circulartests --junitxml=circulartests_junit_report.xml -vv

.PHONY: systemtests
## Run systemtests
systemtests:
	@-export COVERAGE_FILE=.coverage.systemtests;\
	poetry run python -m pytest -k systemtests --junitxml=systemtests_junit_report.xml --cov --cov-config=tests/.coveragerc -vv

.PHONY: tests
## Run all tests
tests: unittests integrationtests clean_tests # systemtests


.PHONY: clean_tests
# Remove pytest cache, junit report after tests
clean_test:
	@-find . -type d -name .pytest_cache | xargs rm -r
	@-find . -type f -name '*junit_report.xml'


.PHONY: coverage
## Combine and build final coverage
coverage:
	@-coverage combine --data-file .coverage || true
	@-coverage html -i
	@-coverage report -i

# ------------------------------------
# Build package
# ------------------------------------

.PHONY: build_pkg
build_pkg:
	@echo "Start to build pkg"
ifeq (True,$(HAS_POETRY))
	@poetry version $(shell git describe --tags --abbrev=0);\
	poetry build
else
	echo "To build the package, you need to have poetry first"
	exit 1
endif

.PHONY: build
## Clean up cache from previous built, and build the package
build: clean_built build_pkg

.PHONY: clean_built
# Remove cache, built package and docs directories after build or installation
clean_built:
	@-find . -type d -name dist | xargs rm -r
	@-find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete

# ------------------------------------
# Build doc
# ------------------------------------

.PHONY: sphinx
## Show sphinx helps
sphinx:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: autodoc
# Clean up bulit docs and build api doc
autodoc:
	@-mkdir -p docs/source/_static
	@-cd docs/source; \
	find -f *.rst ! -name index.rst -delete; \
	cd -
	@$(SPINXAUTODOC) -f -o docs/source ./ ./tests/* ./datamodel/*

.PHONY: html
# Build html files
html:
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: clean_rst
# Clean rst files
clean_rst:
	@-cd docs/source; \
	find -f *.rst ! -name index.rst -delete

.PHONY: doc
## Clean up previous built, run autodoc and build html files
doc: clean_rst autodoc html

# ------------------------------------
# Clean All
# ------------------------------------

.PHONY: clean
## Remove cache, built package and docs directories after build or installation
clean:
	@-find . -type d -name dist | xargs rm -r
	@-find . -type f -name '*.rst' ! -name 'index.rst' -delete
	@-find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete

# ------------------------------------
# Default
# ------------------------------------

.DEFAULT_GOAL := help

help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
