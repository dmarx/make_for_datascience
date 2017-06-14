load("./data/raw/rawdata.rdata")

analyticBaseTable = rawdata

#######################
## Add features here ##
#######################

target_col_ix = which(names(analyticBaseTable) == 'Species')
feats = names(analyticBaseTable[,-target_col_ix])

transformations = list(
  log = log,
  sqrt = sqrt,
  sqrd = function(x) x^2
)

for(f in feats){
  for(trans_name in names(transformations)){
    feat = paste0(f, "_", trans_name)
    trans = transformations[trans_name][[1]]
    analyticBaseTable[,feat] = trans(analyticBaseTable[,f])
  }
}


save(analyticBaseTable, file="./data/processed/analyticBaseTable.rdata")