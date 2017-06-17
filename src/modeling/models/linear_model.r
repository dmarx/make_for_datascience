feats = read.table("data/processed/abt_features.txt", 
                       stringsAsFactors=FALSE)[,1]

# This should be handled in the ABT
ignore_cols = which(feats %in% c('target', 'rec_id'))
if(length(ignore_cols) > 0) feats = feats[,-ignore_cols]

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ ', rhs)

train_model <- function(X, Y, ...){
  X$target = Y
  lm(formula, data=X)
}

predict_model <- function(mod, X, type=NA,  ...){
  scores = predict(mod, newdata=X)
  if(!is.na(type) && type == "class"){
    scores = scores > .5
  }
  scores
}