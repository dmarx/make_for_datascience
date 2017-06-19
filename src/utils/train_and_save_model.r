load("./data/processed/train.rdata")

mod_path <- commandArgs(TRUE)
source(mod_path)

mod <- train_model(X, Y)

#fname = basename(mod_path)
fname = gsub("src/modeling/models/(task.*/.*\\.r)","\\1", mod_path) ## task0/logreg.rdata
stem = strsplit(fname, '\\.r')[1]
outpath = paste0("./models/",stem,".rdata")

save(mod, file=outpath)


