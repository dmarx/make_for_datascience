#~ Non-recursive Make implementation inspired by the tutorial at:
#~   http://www.linux-mag.com/id/2101/

R_INTERPRETER = Rscript
PYTHON_INTERPRETER = python

delete:
	find ./dir* -type f -name 'foo.b' -exec rm {} +
	find ./dir* -type f -name 'X.a' -exec rm {} +
	find ./dir* -type f -name 'Y.a' -exec rm {} +

.PHONY: test build_abt delete taskName

#########################################################
#########################################################
########~ Don't modify anything below this line ~########
#########################################################
#########################################################

# Double colon rules allow included makefiles to redefine the target

## Evaluate models. Set "ARCHIVE=TRUE" to archive old models that may be rebuilt
test::

## Build analytic base tables
build_abt::

## E.g. "make common" or "make task0". Build just the targets for ./subdir 
subdir:
	@echo
	@echo "This isn't a real make target. Specify the name of the subfolder which comprises the modeling task, e.g. 'make task0'"

# Output objects will be placed in the directory defined by _OUTTOP
_OUTTOP ?= .

# By default, don't archive models.
ARCHIVE ?= FALSE
ARCHIVE :=$(strip $ARCHIVE)

# Every listed directory has to have a makefile in it, otherwise make will complain
MODULES=$(patsubst ./%/Makefile,%, $(filter ./%/Makefile,  $(shell find . -type f -name 'Makefile')))

include $(addsuffix /Makefile,$(MODULES))

#~ Code below lifted from the makefile provided by the Cookie Cutter Data science project:
#~   https://github.com/drivendata/cookiecutter-data-science/blob/master/%7B%7B%20cookiecutter.repo_name%20%7D%7D/Makefile

###############################
#~ Self Documenting Commands ~#
###############################

.DEFAULT_GOAL := show-help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: show-help
show-help:
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
