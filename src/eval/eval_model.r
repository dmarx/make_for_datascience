mod_path <- commandArgs(TRUE) # models/%.rdata

load(mod_path) # gets pre-trained `mod`` object
load("./data/processed/test.rdata")

# Get model's predict function
#mod_name     = basename(mod_path)
mod_name = gsub("models/(task.*/.*\\.rdata)","\\1", mod_path) ## task0/logreg.rdata
stem      = strsplit(mod_name, '\\.rdata')[1]
mod_funcs = paste0("src/modeling/models/", stem, '.r')
source(mod_funcs)

scored = predict_model(mod, X, Y, type="class")
confusion <- table(Y, scored)

# Assume mod_path is of the form `models/mod_name.rdata`
##mod_name = basename(mod_path) # This isn't sufficient anymore

fname = paste0("reports/", mod_name, "_holdout_confusion_.txt")
write.csv(confusion, file = fname)
## NB: `save()` doesn't require subfolders to exist, but write.csv apparently does.

source("src/eval/eval_db/dbapi.r")

#m = prep_results(confusion)
m = data.frame(confusion)
m$row_id = 1:nrow(m)
m$field_name = paste0(m$Y, "_", m$scored)
m$value = m$Freq
m = m[,-c(1:3)]

log_model_result(mod_name, "holdout_confusion", m)
dbDisconnect(conn)