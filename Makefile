.PHONY: refresh full_refresh

#################################################################################
# GLOBALS                                                                       #
#################################################################################

R_INTERPRETER = Rscript
PYTHON_INTERPRETER = python

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## assumes each task has a dedicated ABT
#tasks := $(patsubst src/data/%, %, $(shell find src/data -type d))

## assumes each task has a dedicated modeling folder and is named "task.*"
tasks := $(patsubst src/modeling/%, %, $(shell find src/modeling/ -type d | grep task))

##map = $(foreach a,$(2),$(call $(1),$(a)))

r_model_specs := $(wildcard src/modeling/models/task*/*.r)
r_models  := $(patsubst src/modeling/models/%.r, models/%.rdata, $(r_model_specs))

r_reports := $(patsubst src/modeling/models/%, reports/%_holdout_confusion.txt, $(r_model_specs))
r_boots   := $(patsubst src/modeling/models/%, reports/%_bootstrap.txt, $(r_model_specs))
r_ts      := $(patsubst src/modeling/models/%, reports/%_tshuffle.txt,  $(r_model_specs))

r_abt_scripts := $(wildcard src/data/task*/build_base_table.r)
r_abts := $(patsubst src/data/%/build_base_table.r, data/processed/%/analyticBaseTable.rdata, $(r_abt_scripts))

data_path := $(patsubst %/build_bast_table.r, %, $(r_abt_scripts))
train_data := $(data_path)
test_data  := $(wildcard data/processed/task*/test.rdata)

debug:
	echo $(r_abts)
	echo $(r_abt_scripts)

## Train models against full training data
train: $(r_models)

models/%.rdata: src/modeling/models/%.r $(train_data) src/utils/train_and_save_model.r
	$(R_INTERPRETER) src/utils/train_and_save_model.r $<


## Score models against test set
test: reports/all_models_accuracy.txt $(r_models) $(r_boots) $(r_ts) src/eval/eval_db/dbapi.py src/eval/eval_db/dbapi.r

reports/all_models_accuracy.txt: $(r_reports) src/eval/all_models_accuracy.r src/eval/eval_db/dbapi.py
	$(R_INTERPRETER) src/eval/all_models_accuracy.r

$(r_reports): $(r_models) $(test_data) src/eval/eval_model.r src/eval/eval_db/dbapi.py
	$(foreach model_obj, $(r_models), $(R_INTERPRETER) src/eval/eval_model.r $(model_obj);)

## Bootstrap accuracy against training data for all models
bootstrap:$(r_boots) src/eval/eval_db/dbapi.py src/eval/eval_db/dbapi.r

$(r_boots): src/eval/bootstrap.r $(r_model_specs) $(train_data) 
	$(foreach model_spec, $(r_model_specs), $(R_INTERPRETER) $< $(model_spec) accuracy;)

## Target shuffle accuracy against training data for all models (to estimate significance for accuracy)
target_shuffle:$(r_ts) src/eval/eval_db/dbapi.py src/eval/eval_db/dbapi.r

$(r_ts): src/eval/target_shuffle.r $(r_model_specs) $(train_data)
	$(foreach model_spec, $(r_model_specs), $(R_INTERPRETER) $< $(model_spec) accuracy;)


## Flush out all models and processed data, re-run full pipeline via 'test' target
refresh:
	find ./data/processed -type f ! -name '.gitkeep' -exec rm {} +
	find ./models -type f ! -name '.gitkeep' -exec rm {} +
	$(MAKE) test

## Flush out raw data, , re-run full pipeline via 'test' target
full_refresh:
	find ./data/raw -type f ! -name '.gitkeep' -exec rm {} +
	$(MAKE) test

## Flush out all generated objects INCLUDING RAW DATA
delete:
	find ./data -type f ! -name '.gitkeep' -exec rm {} +
	find ./models -type f ! -name '.gitkeep' -exec rm {} +
	find ./reports -type f ! -name '.gitkeep' -exec rm {} +

$(train_data) $(test_data): src/data/train_test_split.r $(r_abts)
#	$(R_INTERPRETER) src/data/train_test_split.r
	$(foreach abt, $(r_abts), $(R_INTERPRETER) $< $(abt);)


## Build the analytic base table by adding features to the raw data
build_abt: $(r_abts)

data/modeling_results.db:
	$(PYTHON_INTERPRETER) src/eval/eval_db/dbapi.py

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################

data/raw/iris_%.csv: src/data/get_raw_data.r
	Rscript src/data/get_raw_data.r

data/processed/sepal_features.rdata: src/data/sepal_features.r data/raw/iris_sepals.csv
	Rscript $<

data/processed/petal_features.rdata: src/data/petal_features.r data/raw/iris_petals.csv
	Rscript $<

data/processed/species_target.rdata: src/data/species_target.r data/raw/iris_species.csv
	Rscript $<

# Complains about circular dependency, drops $(r_abt_scripts dependency. Not sure why.
$(r_abts): $(r_abt_scripts) data/processed/sepal_features.rdata data/processed/petal_features.rdata data/processed/species_target.rdata 
	$(foreach abt_script, $(r_abt_scripts), $(R_INTERPRETER) $(abt_script);)

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
