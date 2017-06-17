load("./data/raw/rawdata.rdata")

analyticBaseTable = rawdata

###########################
## Standardize col names ##
###########################

oldnames = names(analyticBaseTable)
names(analyticBaseTable) = tolower(gsub("\\.", "_", oldnames))

##################
## Add features ##
##################

target_col_ix = which(names(analyticBaseTable) == 'species')
feats = names(analyticBaseTable[,-target_col_ix])

transformations = list(
  log = log,
  sqrt = sqrt,
  sqrd = function(x) x^2
)

new_feats = rep("", length(feats) * length(transformations))
i = 1
for(f in feats){
  for(trans_name in names(transformations)){
    feat = paste0(f, "_", trans_name)
    trans = transformations[trans_name][[1]]
    analyticBaseTable[,feat] = trans(analyticBaseTable[,f])
    
    new_feats[i] = feat
    i = i + 1
  }
}

#######################
## Define the target ##
#######################

analyticBaseTable$target = analyticBaseTable$species == 'versicolor'
analyticBaseTable = analyticBaseTable[,-target_col_ix]

#######################################
## Assign a unique ID to each record ##
#######################################

analyticBaseTable$rec_id = seq_along(nrow(analyticBaseTable))

########################################
## Save ABT and features list to disk ##
########################################

feats = c(feats, new_feats)
write.table(feats, "data/processed/abt_features.txt", 
            col.names=FALSE, row.names=FALSE, quote=FALSE)

save(analyticBaseTable, file="./data/processed/analyticBaseTable.rdata")