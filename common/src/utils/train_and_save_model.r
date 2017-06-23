outpath <- commandArgs(TRUE) ## task0/logreg.rdata

task_name = gsub("(task.*)/models/(.*\\.r)data","\\1", outpath) 
mod_name = gsub("(task.*)/models/(.*\\.r)data","\\2", outpath)

data_path = paste0(task_name, "/data/processed/train.rdata")
load(data_path) 

mod_funcs = paste0(task_name, "/src/models/", mod_name)
source(mod_funcs)

mod <- suppressWarnings(train_model(X, Y))

model_path = paste0(task_name, "/models")
dir.create(model_path, showWarnings = FALSE)

save(mod, file=outpath)


