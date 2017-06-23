##########################################
#~ Project-generic source/target search ~#
##########################################

r_model_specs := $(wildcard $(_MODULE)/src/models/*.r)
r_mod_names := $(notdir $(r_model_specs))
r_models  := $(patsubst %,$(_MODULE)/models/%data, r_mod_names)


#train_data := $(_MODULE)/data/processed/train.rdata
#test_data  := $(_MODULE)/data/processed/test.rdata
#abt := $(_MODULE)/data/processed/analyticBaseTable.rdata
#abt_script := $(_MODULE)/src/data/build_base_table.r

train_data := data/processed/train.rdata
test_data  := data/processed/test.rdata
abt := data/processed/analyticBaseTable.rdata
abt_script := src/data/build_base_table.r

#r_test_acc := $(patsubst %,$(_MODULE)/results/%_holdout_confusion.txt, r_mod_names)

TGTS := $(abt) $(train_data) $(test_data) $(patsubst %,models/%data, $(r_mod_names))
###########################
#~ Project-generic rules ~#
###########################

## THIS IS GOOD. Using $(_MODULE)/ in the rule works as expected
#$(_MODULE)/target/%.b: $(_MODULE)/source/%.a
#	./operation1.sh $< $@

### THIS IS BAD. Using $(_MODULE)/ in the recipe causes unexpected behavior. The rule will likely
### Be repeated for each directory it should run for, but will only evaluate the recipe for the 
### last directory processed.
#$(_MODULE)/target/%.b: $(_MODULE)/source/%.a $(_MODULE)/operation1.sh
#	$(_MODULE)/operation1.sh $< $@

#~~ For reference: this version of the train/test split rule results in running the task0 buld abt script but passing in the task1 abt
# Ergo: simple $(_MODULE)/ prefix works correctly in the rule, but not in the recipe. 
# Beware. Here there be dragons.
#$(_MODULE)/$(train_data) $(_MODULE)/$(test_data): common/src/data/train_test_split.r $(_MODULE)/$(abt)
#	$(R_INTERPRETER) $< $(_MODULE)/$(abt)

###########################################

#$(_MODULE)/results/%_holdout_confusion.txt: $(_MODULE)/models/%.rdata $(_MODULE)/$(test_data) common/src/eval/eval_model.r common/src/eval/eval_db/dbapi.py
####	$(R_INTERPRETER) common/src/eval/eval_model.r $< $@ ### Would prob make more sense if I passed in the model than the output
#	$(R_INTERPRETER) common/src/eval/eval_model.r $@

#$(r_models): common/src/utils/train_and_save_model.r $(r_model_specs) $(train_data)
$(_MODULE)/models/%.rdata: $(_MODULE)/src/models/%.r common/src/utils/train_and_save_model.r  $(_MODULE)/$(train_data)
#	$(foreach outfile, $@, $(R_INTERPRETER) $< $(outfile);)
	$(R_INTERPRETER) common/src/utils/train_and_save_model.r $@

$(_MODULE)/$(train_data) $(_MODULE)/$(test_data): $(_MODULE)/$(abt) common/src/data/train_test_split.r
	$(R_INTERPRETER) common/src/data/train_test_split.r $<

$(_MODULE)/$(abt): $(_MODULE)/$(abt_script) common/data/processed/sepal_features.rdata common/data/processed/petal_features.rdata common/data/processed/species_target.rdata
#	$(R_INTERPRETER) $(patsubst %/data/processed/analyticBaseTable.rdata, %/src/data/build_base_table.r, $@)
	$(R_INTERPRETER) $<



#########################################################    
########~ Don't modify anything below this line ~########
#########################################################

$(_MODULE)_TGTS := $(addprefix $($(_MODULE)_OUTPUT)/,$(TGTS))
#$(_MODULE)_TGTS := $($(TGTS))

debug::
	echo $($(_MODULE)_TGTS)

#all:: $($(_MODULE)_TGTS)
#all:: $(_MODULE)
test:: $(_MODULE)
$(_MODULE): $($(_MODULE)_TGTS)

build_abt:: $(_MODULE)/data/processed/analyticBaseTable.rdata
