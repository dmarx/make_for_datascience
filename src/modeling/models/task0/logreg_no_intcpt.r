feats = read.table("data/processed/task0/abt_features.txt", 
                   stringsAsFactors=FALSE)[,1]

# This should be handled in the ABT
ignore_cols = which(feats %in% c('target', 'rec_id'))
if(length(ignore_cols) > 0) feats = feats[,-ignore_cols]

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ -1 +', rhs)

train_model <- function(X, Y, ...){
  X$target = Y
  glm(formula, data=X, family=binomial)
}

predict_model <- function(mod, X, type=NA, ...){
  scores = predict(mod, newdata=X, type="response")
  if(!is.na(type) && type == "class"){
    scores = scores > .5
  }
  scores
}