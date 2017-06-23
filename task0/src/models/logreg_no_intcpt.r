train_model <- function(X, Y, ...){
  feats = read.table("task0/data/processed/abt_features.txt", stringsAsFactors=FALSE)[,1]
  rhs = paste(feats, collapse=" + ")
  formula = paste0('target ~ -1 + ', rhs)
  
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