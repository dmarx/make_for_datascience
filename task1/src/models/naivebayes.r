library(e1071)

train_model <- function(X, Y, ...){
  feats = read.table("task1/data/processed/abt_features.txt", stringsAsFactors=FALSE)[,1]
  naiveBayes(X[feats], Y)
}

predict_model <- function(mod, X, type="raw", ...){
  predict(mod, newdata=X, type=type)
}