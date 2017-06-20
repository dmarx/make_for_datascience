mod_funcs <- commandArgs(TRUE)
source(mod_funcs)


mod_name = gsub("src/modeling/models/(task.*/.*\\.r)","\\1", mod_funcs) ## task0/logreg.rdata
task_name = dirname(mod_name)
data_path = paste0("data/processed/", task_name, "/train.rdata")
print(c("DATA_PATH", data_path))
load(data_path) 

mod <- train_model(X, Y)

model_path = paste0("models/", task_name)
dir.create(model_path, showWarnings = FALSE)

outpath = paste0("models/",mod_name,"data")

save(mod, file=outpath)


