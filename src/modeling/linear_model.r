load("./data/processed/train.rdata")

ignore_cols = which(names(X) %in% c('target', 'rec_id'))
feats = names(X[,-ignore_cols])

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