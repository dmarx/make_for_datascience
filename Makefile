.PHONY: full_refresh

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
BUCKET = [OPTIONAL] your-bucket-for-syncing-data (do not include 's3://')
PROJECT_NAME = iris_test
PYTHON_INTERPRETER = python3
########R_INTERPRETER = /cygdrive/c/Program\ Files/R/R-3.2.2/bin/R CMD BATCH
R_INTERPRETER = Rscript

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## Flush out all models and non-raw data, re-run full pipeline via 'test' target
refresh_models:
	find ./data/processed -type f ! -name '.gitkeep' -exec rm {} +
	find ./data/external -type f ! -name '.gitkeep' -exec rm {} +
	find ./data/interim -type f ! -name '.gitkeep' -exec rm {} +
	find ./models -type f ! -name '.gitkeep' -exec rm {} +
	$(MAKE) test

## Flush out raw data, , re-run full pipeline via 'test' target
full_refresh:
	find ./data/raw -type f ! -name '.gitkeep' -exec rm {} +
	$(MAKE) test

## Make Dataset
data: ./data/processed/train.rdata ./data/processed/test.rdata

./data/processed/train.rdata ./data/processed/test.rdata: ./data/raw/iris.rdata
	Rscript ./src/data/train_test_split.r

./data/raw/iris.rdata:
	Rscript -e 'data(iris); save(iris, file=\"./data/raw/iris.rdata\")'
    
## Train logistic regression classifier on training data
train: ./models/simple_logistic.rdata

./models/simple_logistic.rdata: ./data/processed/train.rdata ./data/processed/test.rdata
	Rscript src/models/train_classifier_logreg.r

## Score model against test set
test: ./models/simple_logistic.rdata ./reports/confusion_metrix.txt

./reports/confusion_metrix.txt: ./models/simple_logistic.rdata ./data/processed/test.rdata
	Rscript src/models/eval_model.r

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################



#################################################################################
# Self Documenting Commands                                                     #
#################################################################################

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
