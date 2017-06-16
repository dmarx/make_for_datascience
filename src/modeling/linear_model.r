load("./data/processed/train.rdata")

ignore_cols = which(names(train) %in% c('target', 'rec_id'))
feats = names(train[,-ignore_cols])

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ ', rhs)

train_model <- function(data, ...){
  lm(formula, data=train)
}

predict_model <- function(mod, data, type=NA,  ...){
  scores = predict(mod, newdata=data)
  if(!is.na(type) && type == "class"){
    scores = scores > .5
  }
  scores
}