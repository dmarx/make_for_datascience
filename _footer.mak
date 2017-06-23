##########################################
#~ Project-generic source/target search ~#
##########################################

train_data := data/processed/train.rdata
test_data  := data/processed/test.rdata
abt := data/processed/analyticBaseTable.rdata
abt_script := src/data/build_base_table.r

r_model_specs := $(wildcard $(_MODULE)/src/models/*.r)
r_mod_names := $(notdir $(r_model_specs))

r_test_acc := $(patsubst %,reports/%_holdout_confusion.txt, $(r_mod_names))

TGTS += $(abt) $(train_data) $(test_data) 
TGTS += $(patsubst %,models/%data, $(r_mod_names))
TGTS += $(r_test_acc)
TGTS += $(patsubst %,reports/%_bootstrap.txt, $(r_mod_names))
TGTS += $(patsubst %,reports/%_tshuffle.txt, $(r_mod_names))
TGTS += reports/all_models_accuracy.txt

###########################
#~ Project-generic rules ~#
###########################

#~ THIS IS GOOD:
#~
#~      $(_MODULE)/target/%.b: $(_MODULE)/source/%.a ./operation.sh
#~      	./operation.sh $< $@
#~
#~  Using $(_MODULE)/ in the rule works as you'd expected.
#~
#~
#~ THIS IS BAD:
#~
#~      $(_MODULE)/target/%.b: $(_MODULE)/source/%.a $(_MODULE)/operation.sh
#~      	$(_MODULE)/operation.sh $< $@
#~
#~  Using $(_MODULE)/ in the recipe causes unexpected behavior. The rule will likely
#~  Be repeated for each directory it should run for, but will only evaluate the recipe for the 
#~  last directory processed.
#~
#~ DO THIS INSTEAD:
#~
#~      $(_MODULE)/target/%.b: $(_MODULE)/source/%.a $(_MODULE)/operation.sh
#~      	$(eval _dir := $(patsubst %/target/,%, $(dir $@)))
#~      	$(_dir)/operation.sh $< $@
#~
#~  We can extract the task dir from $@ in the recipe, and then use $(eval ) to get
#~  the directory-specific value we need inside the recipe.

$(_MODULE)_EVAL_METRIC := $(_EVAL_METRIC)

$(_MODULE)/reports/all_models_accuracy.txt: $(addprefix $(_MODULE)/,$(r_test_acc)) common/src/eval/all_models_accuracy.r common/src/eval/eval_db/dbapi.py common/src/eval/eval_db/dbapi.r
	$(R_INTERPRETER) common/src/eval/all_models_accuracy.r

$(_MODULE)/reports/%.r_tshuffle.txt: $(_MODULE)/models/%.rdata $(_MODULE)/$(test_data) common/src/eval/target_shuffle.r common/src/eval/basic_stats.r common/src/eval/eval_db/dbapi.py common/src/eval/eval_db/dbapi.r
	$(eval _dir := $(patsubst %/reports/,%, $(dir $@)))
	$(R_INTERPRETER) common/src/eval/target_shuffle.r $@ $($(_dir)_EVAL_METRIC)

$(_MODULE)/reports/%.r_bootstrap.txt: $(_MODULE)/models/%.rdata $(_MODULE)/$(test_data) common/src/eval/bootstrap.r common/src/eval/basic_stats.r common/src/eval/eval_db/dbapi.py common/src/eval/eval_db/dbapi.r
	$(eval _dir := $(patsubst %/reports/,%, $(dir $@)))
	$(R_INTERPRETER) common/src/eval/bootstrap.r $@ $($(_dir)_EVAL_METRIC)

$(_MODULE)/reports/%.r_holdout_confusion.txt: $(_MODULE)/models/%.rdata $(_MODULE)/$(test_data) common/src/eval/eval_model.r common/src/eval/eval_db/dbapi.py common/src/eval/eval_db/dbapi.r
	$(R_INTERPRETER) common/src/eval/eval_model.r $@


$(_MODULE)_ARCHIVE := $(ARCHIVE)

$(_MODULE)/models/%.rdata: $(_MODULE)/src/models/%.r common/src/utils/train_and_save_model.r $(_MODULE)/$(train_data) common/src/utils/archive_model.r
	$(eval _dir := $(patsubst %/models/,%, $(dir $@)))
	if [ "$($(_dir)_ARCHIVE)" = "TRUE" ]; then $(R_INTERPRETER) common/src/utils/archive_model.r $@; fi
	$(R_INTERPRETER) common/src/utils/train_and_save_model.r $@
	

$(_MODULE)/$(train_data) $(_MODULE)/$(test_data): $(_MODULE)/$(abt) common/src/data/train_test_split.r
	$(R_INTERPRETER) common/src/data/train_test_split.r $<

$(_MODULE)/$(abt): $(_MODULE)/$(abt_script) common/data/processed/sepal_features.rdata common/data/processed/petal_features.rdata common/data/processed/species_target.rdata
	$(R_INTERPRETER) $<

$(_MODULE)_TGTS := $(addprefix $($(_MODULE)_OUTPUT)/,$(TGTS))

debug::
	echo $($(_MODULE)_TGTS)

test:: $(_MODULE)

$(_MODULE): $($(_MODULE)_TGTS)

build_abt:: $(_MODULE)/data/processed/analyticBaseTable.rdata
