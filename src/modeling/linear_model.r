load("./data/processed/train.rdata")

ignore_cols = which(names(train) %in% c('target', 'rec_id'))
feats = names(train[,-ignore_cols])

rhs = paste(feats, collapse=" + ")
formula = paste0('target ~ ', rhs)

mod <- lm(formula, data=train, family=binomial)

this_script <- commandArgs(TRUE)
fname = basename(this_script)
stem = strsplit(fname, '\\.r')[1]
outpath = paste0("./models/",stem,".rdata")

save(mod, file=outpath)