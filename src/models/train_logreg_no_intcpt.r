load("./data/processed/train.rdata")

feats = names(train[,-5])
train$target = train$Species == 'versicolor'

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ -1 +', rhs)

mod <- glm(formula, data=train, family=binomial)

save(mod, file="./models/logreg_no_intcpt.rdata")