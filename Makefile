.PHONY: refresh full_refresh

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

r_models  := $(patsubst src/models/train_%.r, models/%.rdata, $(wildcard src/models/train_*.r))
r_reports := $(patsubst models/%.rdata, reports/confusion_matrix_%.txt, $(r_models))

## Train models
train: $(r_models)

models/%.rdata: src/models/train_%.r ./data/processed/train.rdata
	$(R_INTERPRETER) $<


## Score models against test set
test: reports/all_models_accuracy.txt

reports/confusion_matrix_%.txt: models/%.rdata data/processed/test.rdata src/models/eval_model.r
	$(R_INTERPRETER) src/models/eval_model.r $<

reports/all_models_accuracy.txt: $(r_reports)
	$(R_INTERPRETER) src/models/all_models_accuracy.r


## Flush out all models and non-raw data, re-run full pipeline via 'test' target
refresh:
	find ./data/processed -type f ! -name '.gitkeep' -exec rm {} +
	find ./data/external -type f ! -name '.gitkeep' -exec rm {} +
	find ./data/interim -type f ! -name '.gitkeep' -exec rm {} +
	find ./models -type f ! -name '.gitkeep' -exec rm {} +
	$(MAKE) test

## Flush out raw data, , re-run full pipeline via 'test' target
full_refresh:
	find ./data/raw -type f ! -name '.gitkeep' -exec rm {} +
	$(MAKE) test


## Make Dataset (assumes a project rule has been defined to generate ./data/raw/raw.rdata
data: ./data/processed/train.rdata ./data/processed/test.rdata

data/processed/train.rdata data/processed/test.rdata: data/raw/rawdata.rdata
	$(R_INTERPRETER) src/data/train_test_split.r

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################

data/raw/rawdata.rdata:
	Rscript src/data/build_raw_data.r

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
