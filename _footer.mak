##########################################
## Project-generic source/target search ##
##########################################

r_model_specs := $(wildcard $(_MODULE)/src/models/*.r)
r_models  := $(patsubst %,$(_MODULE)/models/%data, $(notdir $(r_model_specs)) )

###########################
## Project-generic rules ##
###########################

#$(_MODULE)/target/%.b: $(_MODULE)/source/%.a
#	./operation1.sh $< $@



$(_MODULE)/data/processed/analyticBaseTable.rdata: $(_MODULE)/src/data/build_base_table.r common/data/processed/sepal_features.rdata common/data/processed/petal_features.rdata common/data/processed/species_target.rdata
	$(R_INTERPRETER) $(patsubst %/data/processed/analyticBaseTable.rdata, %/src/data/build_base_table.r, $@)



#########################################################    
######### Don't modify anything below this line #########
#########################################################

$(_MODULE)_TGTS := $(addprefix $($(_MODULE)_OUTPUT)/,$(TGTS))

#all:: $($(_MODULE)_TGTS)
#all:: $(_MODULE)
test:: $(_MODULE)
$(_MODULE): $($(_MODULE)_TGTS)

build_abt:: $(_MODULE)/data/processed/analyticBaseTable.rdata
