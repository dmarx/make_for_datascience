load("./data/processed/train.rdata")

ignore_cols = which(names(train) %in% c('target', 'rec_id'))
feats = names(train[,-ignore_cols])

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ -1 +', rhs)

train_model <- function(data, ...){
  glm(formula, data=train, family=binomial)
}

predict_model <- function(mod, data, ...){
  predict(mod, newdata=data, type="response")
}