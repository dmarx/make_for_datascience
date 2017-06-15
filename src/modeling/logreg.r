load("./data/processed/train.rdata")

target_col_ix = which(names(train) == 'Species')
feats = names(train[,-target_col_ix])
train$target = train$Species == 'versicolor'

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ ', rhs)

mod <- glm(formula, data=train, family=binomial)

this_script <- commandArgs(TRUE)
fname = basename(this_script)
stem = strsplit(fname, '\\.r')[1]
outpath = paste0("./models/",stem,".rdata")

save(mod, file=outpath)
