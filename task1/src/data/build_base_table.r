# NB: All feature engineering should be accomplished in dedicated files external
# to this script to ensure that ABTs that rely on similar features are all
# drawing those features from the same construction process. This strip should
# just be a merging of features constructed elsewhere into a unified ABT for
# a specific modeling task.

####################################
## Merge feature sets into an ABT ##
####################################

load("common/data/processed/sepal_features.rdata")

all_features = sepal_features

####################################
## Merge target variable onto ABT ##
####################################

load("common/data/processed/species_target.rdata")

analyticBaseTable = merge(all_features, species_target[, c("Flower.Id", "Species")])
old_names = names(analyticBaseTable)
ix = which(old_names == "Species")
names(analyticBaseTable)[ix] = "target"

###########################
## Standardize col names ##
###########################

oldnames = names(analyticBaseTable)
names(analyticBaseTable) = tolower(gsub("\\.", "_", oldnames))

#######################################
## Assign a unique ID to each record ##
#######################################

# This has already been done for us
# with the Flower.Id variabl
#analyticBaseTable$rec_id = seq_along(nrow(analyticBaseTable))

uniq_id_col = "flower_id"
uniq_in_col = length(unique(analyticBaseTable[,uniq_id_col]))

# Sanity check
stopifnot( uniq_in_col == nrow(analyticBaseTable) )

########################################
## Save ABT and features list to disk ##
########################################

# Prevent future leaks
ignore_cols = c("flower_id", "target", "species")

all_col_names = names(analyticBaseTable)
feats = all_col_names[-which(all_col_names %in% ignore_cols)]
data_path = "task1/data/processed/"
dir.create(data_path, showWarnings = TRUE, recursive=TRUE)
write.table(feats, file=paste0(data_path, "abt_features.txt"),
            col.names=FALSE, row.names=FALSE, quote=FALSE)

save(analyticBaseTable, file=paste0(data_path, "analyticBaseTable.rdata"))
