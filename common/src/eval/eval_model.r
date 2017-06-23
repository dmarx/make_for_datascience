outpath <- commandArgs(TRUE) ## task0/reports/logreg.r_holdout_confusion.txt

task_name = gsub("(task.*)/reports/(.*\\.r)_holdout_confusion.txt","\\1", outpath)
mod_name  = gsub("(task.*)/reports/(.*\\.r)_holdout_confusion.txt","\\2", outpath)
mod_path = paste0(task_name, "/models/", mod_name, "data")

load(mod_path) # gets pre-trained `mod`` object

data_path = paste0(task_name, "/data/processed/", "/test.rdata")
load(data_path) 

mod_funcs = paste0(task_name, "/src/models/", mod_name)
source(mod_funcs)

scored = predict_model(mod, X, Y, type="class")
confusion <- table(Y, scored)

dir.create(dirname(outpath), showWarnings = FALSE)
write.csv(confusion, file = outpath)

source("common/src/eval/eval_db/dbapi.r")

m = data.frame(confusion)
m$row_id = 1:nrow(m)
m$field_name = paste0(m$Y, "_", m$scored)
m$value = m$Freq
m = m[,-c(1:3)]

result_name = "holdout_confusion"
log_model_result(task_name, mod_name, result_name, m)
dbDisconnect(conn)