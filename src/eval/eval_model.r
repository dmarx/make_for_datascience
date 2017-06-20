outpath <- commandArgs(TRUE) ## reports/task0/logreg.r_holdout_confusion.txt

mod_name = gsub("reports/(task.*/.*\\.r)_holdout_confusion.txt","\\1", outpath)
mod_path = paste0("models/", mod_name, "data")

load(mod_path) # gets pre-trained `mod`` object

task_name = dirname(mod_name)
data_path = paste0("data/processed/", task_name, "/test.rdata")
load(data_path) 

mod_funcs = paste0("src/modeling/models/", mod_name)
source(mod_funcs)

scored = predict_model(mod, X, Y, type="class")
confusion <- table(Y, scored)

fname = paste0("reports/", mod_name, "_holdout_confusion.txt")
dir.create(dirname(fname), showWarnings = FALSE)
write.csv(confusion, file = fname)

source("src/eval/eval_db/dbapi.r")

m = data.frame(confusion)
m$row_id = 1:nrow(m)
m$field_name = paste0(m$Y, "_", m$scored)
m$value = m$Freq
m = m[,-c(1:3)]

log_model_result(mod_name, "holdout_confusion", m)
dbDisconnect(conn)