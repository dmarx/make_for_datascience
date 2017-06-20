mod_funcs <- commandArgs(TRUE)
source(mod_funcs)


mod_name = gsub("src/modeling/models/(task.*/.*\\.r)","\\1", mod_funcs) ## task0/logreg.rdata
task_name = dirname(mod_name)
data_path = paste0("data/processed/", task_name, "/train.rdata")

load(data_path) 

mod <- train_model(X, Y)


stem = strsplit(mod_name, '\\.r')[1]
outpath = paste0("./models/",stem,".rdata")

save(mod, file=outpath)


