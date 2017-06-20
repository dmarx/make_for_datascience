source('src/utils/apply_transformations.r')

petals = read.csv("data/raw/iris_petals.csv")

feats = names(petals)
ignore_cols = c("Flower.Id")
feats = feats[-which(feats %in% ignore_cols)]

transformations = list(
  log1p = log1p,
  cubd = function(x) x^3
)

addl_features = apply_transformations(petals, feats, transformations)

petal_features = cbind(petals, addl_features)
save(petal_features, file='data/processed/petal_features.rdata')