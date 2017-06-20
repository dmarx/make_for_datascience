train_model <- function(X, Y, ...){
  feats = read.table("task0/data/processed/abt_features.txt", stringsAsFactors=FALSE)[,1]
  rhs = paste(feats, collapse=" + ")
  formula = paste0('target ~ ', rhs)
  
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