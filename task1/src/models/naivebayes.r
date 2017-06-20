feats = read.table("data/processed/task1/abt_features.txt", 
                   stringsAsFactors=FALSE)[,1]

# This should be handled in the ABT
ignore_cols = which(feats %in% c('target', 'rec_id'))
if(length(ignore_cols) > 0) feats = feats[,-ignore_cols]

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ ', rhs)

library(e1071)

train_model <- function(X, Y, ...){
  #X$target = Y
  #naiveBayes(formula, data=X)
  naiveBayes(X[feats], Y)
}

predict_model <- function(mod, X, type="raw", ...){
  predict(mod, newdata=X, type=type)
}