#mod_funcs <- commandArgs(TRUE)
#source(mod_funcs)
outpath <- commandArgs(TRUE)
#source(mod_funcs)


#mod_name = gsub("src/modeling/models/(task.*/.*\\.r)","\\1", mod_funcs) ## task0/logreg.rdata
mod_name = gsub("models/(task.*/.*\\.r)data","\\1", outpath) ## task0/logreg.rdata
task_name = dirname(mod_name)

data_path = paste0("data/processed/", task_name, "/train.rdata")
load(data_path) 

mod_funcs = paste0("src/modeling/models/", mod_name)
source(mod_funcs)

mod <- train_model(X, Y)

model_path = paste0("models/", task_name)
dir.create(model_path, showWarnings = FALSE)

#outpath = paste0("models/",mod_name,"data")

save(mod, file=outpath)


