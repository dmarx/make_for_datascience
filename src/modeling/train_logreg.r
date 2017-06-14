load("./data/processed/train.rdata")

target_col_ix = which(names(train) == 'Species')
feats = names(train[,-target_col_ix])
train$target = train$Species == 'versicolor'

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ ', rhs)

mod <- glm(formula, data=train, family=binomial)

save(mod, file="./models/logreg.rdata")
