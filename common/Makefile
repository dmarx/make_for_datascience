# _header.mak and _footer.mak only necessary in modeling task directories.
# In fact, including _footer.mak will break this.

#######################################
#~ Ensure modeling_results.db exists ~#
#######################################

test:: common/data/modeling_results.db

common/data/modeling_results.db:common/src/eval/eval_db/dbapi.py
	$(PYTHON_INTERPRETER) common/src/eval/eval_db/dbapi.py

#~ Don't edit anything above this line ~#

#~ Put the common data pipeline below ~#
    
######################
#~ Getting raw data ~#
######################

common/data/raw/iris_%.csv: common/src/data/get_raw_data.r
	Rscript common/src/data/get_raw_data.r

####################################
#~ Feature and target engineering ~#
####################################
    
common/data/processed/sepal_features.rdata: common/src/data/sepal_features.r common/data/raw/iris_sepals.csv
	Rscript $<

common/data/processed/petal_features.rdata: common/src/data/petal_features.r common/data/raw/iris_petals.csv
	Rscript $<

common/data/processed/species_target.rdata: common/src/data/species_target.r common/data/raw/iris_species.csv
	Rscript $<