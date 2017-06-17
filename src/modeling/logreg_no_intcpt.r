ignore_cols = which(names(X) %in% c('target', 'rec_id'))
feats = names(X[,-ignore_cols])

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