abt_path <- commandArgs(TRUE)[1]
data_path = dirname(abt_path)
load(abt_path)


n = nrow(analyticBaseTable)
ix = sample(n, .8*n)

target_col_ix = which(names(analyticBaseTable) == 'target')

X <- analyticBaseTable[ix,-target_col_ix]
Y <- analyticBaseTable[ix,target_col_ix]
save(X, Y, file=paste0(data_path,"/train.rdata"))

X <- analyticBaseTable[-ix,-target_col_ix]
Y <- analyticBaseTable[-ix,target_col_ix]
save(X, Y, file=paste0(data_path,"/test.rdata"))
