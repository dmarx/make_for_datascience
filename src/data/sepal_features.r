source('src/utils/apply_transformations.r')

sepals = read.csv("data/raw/iris_sepals.csv")

feats = names(sepals)
ignore_cols = c("Flower.Id")
feats = feats[-which(feats %in% ignore_cols)]

transformations = list(
  log = log,
  sqrt = sqrt,
  sqrd = function(x) x^2
)

addl_features = apply_transformations(sepals, feats, transformations)

sepal_features = cbind(sepals, addl_features)
save(sepal_features, file='data/processed/sepal_features.rdata')