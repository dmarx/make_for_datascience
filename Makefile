.PHONY: refresh full_refresh

#################################################################################
# GLOBALS                                                                       #
#################################################################################

R_INTERPRETER = Rscript
PYTHON_INTERPRETER = python

#################################################################################
# COMMANDS                                                                      #
#################################################################################

## assumes each task has a dedicated ABT. Alternatively, could target 
## src/modeling/models/task*/foobar.r
## Although tasks could theoretically share an ABT, we shouldn't rely on modeling
## scripts for this since it would hinder pipelining exploration. If necessary,
## a task with a shared ABT could just copy an existing ABT into a new folder or
## create a symlink/shortcut to the existing ABT in the appropriate task dir.
tasks := $(filter task%, $(shell ls))

r_model_specs := $(wildcard */src/models/*.r)
r_models  := $(foreach spec, $(r_model_specs), $(shell echo $(spec) | awk -F "/" '{print $$1"/models/"$$4"data"}' ) ) 

r_test_acc := $(foreach spec, $(r_model_specs), $(shell echo $(spec) | awk -F "/" '{print $$1"/reports/"$$4"_holdout_confusion.txt"}' ) )
r_boots    := $(foreach spec, $(r_model_specs), $(shell echo $(spec) | awk -F "/" '{print $$1"/reports/"$$4"_bootstrap.txt"}' ) )
r_ts       := $(foreach spec, $(r_model_specs), $(shell echo $(spec) | awk -F "/" '{print $$1"/reports/"$$4"_tshuffle.txt"}' ) )
r_all_acc  := $(patsubst %, reports/%/all_models_accuracy.txt,  $(tasks))

r_abt_scripts := $(wildcard task*/src/data/build_base_table.r)
r_abts := $(patsubst %, %/data/processed/analyticBaseTable.rdata,  $(tasks))

train_data := $(patsubst %, %/data/processed/train.rdata, $(tasks))
test_data  := $(patsubst %, %/data/processed/test.rdata, $(tasks))

debug: task0/data/processed/train.rdata
	echo $(train_data)
	echo $<
	echo $(shell echo $$< | awk -F "/" '{print $$1"/data/processed/analyticBaseTable.rdata"}' )


## Train models against full training data
train: $(r_models)

$(r_models): common/src/utils/train_and_save_model.r $(r_model_specs) $(train_data)
	$(foreach outfile, $@, $(R_INTERPRETER) $< $(outfile);)

## Score models against test set
test: $(r_all_acc) $(r_models) $(r_boots) $(r_ts) common/src/eval/eval_db/dbapi.py common/src/eval/eval_db/dbapi.r

# I don't think there's anything I can do to fix this rule.
$(r_all_acc): $(r_test_acc) common/src/eval/all_models_accuracy.r common/src/eval/eval_db/dbapi.py
	$(R_INTERPRETER) common/src/eval/all_models_accuracy.r

$(r_test_acc): common/src/eval/eval_model.r $(r_models) $(test_data) common/src/eval/eval_db/dbapi.py
	$(foreach outfile, $@, $(R_INTERPRETER) $< $(outfile);)

## Bootstrap accuracy against training data for all models
bootstrap:$(r_boots) common/src/eval/eval_db/dbapi.py common/src/eval/eval_db/dbapi.r

$(r_boots): common/src/eval/bootstrap.r $(r_model_specs) $(train_data)
	$(foreach outfile, $@, $(R_INTERPRETER) $< $(outfile) accuracy;)

## Target shuffle accuracy against training data for all models (to estimate significance for accuracy)
target_shuffle:$(r_ts) common/src/eval/eval_db/dbapi.py common/src/eval/eval_db/dbapi.r

$(r_ts): common/src/eval/target_shuffle.r $(r_model_specs) $(train_data)
	$(foreach outfile, $@, $(R_INTERPRETER) $< $(outfile) accuracy;)

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

    ## %/data/processed/train.rdata
    ## %/data/processed/analyticBaseTable.rdata
    ## $(shell echo $@ | awk -F "/" '{print $$1"/data/processed/analyticBaseTable.rdata"}' )
$(train_data) $(test_data): common/src/data/train_test_split.r $(patsubst %/data/processed/train.rdata, %/data/processed/analyticBaseTable.rdata, $@) $(patsubst %/data/processed/test.rdata, %/data/processed/analyticBaseTable.rdata, $@)
	$(eval tgt_abt_trn := $(patsubst %/data/processed/train.rdata, %/data/processed/analyticBaseTable.rdata, $@) )
	$(eval tgt_abt_tst := $(patsubst %/data/processed/test.rdata, %/data/processed/analyticBaseTable.rdata, $@) )
	$(eval candidates := $(tgt_abt_trn) $(tgt_abt_tst) )
	$(eval abt:=$(filter %analyticBaseTable.rdata, $(candidates)))
	$(R_INTERPRETER) $< $(abt)


## Build the analytic base table by adding features to the raw data
build_abt: $(r_abts)

common/data/modeling_results.db:
	$(PYTHON_INTERPRETER) common/src/eval/eval_db/dbapi.py

#################################################################################
# PROJECT RULES                                                                 #
#################################################################################

common/data/raw/iris_%.csv: common/src/data/get_raw_data.r
	Rscript common/src/data/get_raw_data.r

common/data/processed/sepal_features.rdata: common/src/data/sepal_features.r common/data/raw/iris_sepals.csv
	Rscript $<

common/data/processed/petal_features.rdata: common/src/data/petal_features.r common/data/raw/iris_petals.csv
	Rscript $<

common/data/processed/species_target.rdata: common/src/data/species_target.r common/data/raw/iris_species.csv
	Rscript $<


$(r_abts): $(patsubst %/data/processed/analyticBaseTable.rdata, %/src/data/build_base_table.r, $@) common/data/processed/sepal_features.rdata common/data/processed/petal_features.rdata common/data/processed/species_target.rdata
	$(R_INTERPRETER) $(patsubst %/data/processed/analyticBaseTable.rdata, %/src/data/build_base_table.r, $@)


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
