load("./data/processed/train.rdata")

feats = names(train[,-5])
train$target = train$Species == 'versicolor'

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ ', rhs)

mod <- lm(formula, data=train, family=binomial)

save(mod, file="./models/linear_model.rdata")