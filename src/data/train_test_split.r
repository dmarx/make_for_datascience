load("./data/processed/analyticBaseTable.rdata")

n = nrow(analyticBaseTable)
ix = sample(n, .8*n)

target_col_ix = which(names(analyticBaseTable) == 'target')

X <- analyticBaseTable[ix,-target_col_ix]
Y <- analyticBaseTable[ix,target_col_ix]
save(X, Y, file="./data/processed/train.rdata")

X <- analyticBaseTable[-ix,-target_col_ix]
Y <- analyticBaseTable[-ix,target_col_ix]
save(X, Y, file="./data/processed/test.rdata")